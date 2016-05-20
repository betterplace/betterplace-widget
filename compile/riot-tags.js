riot.tag2('project', '<div class="image" riot-style="background-image: url(\'{profile_picture}\');"></div><section class="content"><h1>{record.title}</h1><div class="limited-width"><div class="progress-bar" if="{record.progress_percentage}"><div class="bar" riot-style="width: {record.progress_percentage}%"></div></div><div if="{!record.donations_prohibited}" class="project-values"><div class="donor-count"><div class="value">{record.donor_count}</div> {t.donor_count} </div><div if="{record.progress_percentage}" class="progress-percentage"><div class="value">{record.progress_percentage} %</div> {t.financed} </div></div><div class="project-status-message" if="{record.donations_prohibited}"> {t.donations_prohibited} </div><a target="_blank" class="button button-block" if="{!record.donations_prohibited}" href="{visit_url}">{t.donate}</a><a target="_blank" class="button button-block" if="{record.donations_prohibited}" href="{visit_url}">{t.visit}</a></div><div class="logo" if="{client.widget_logo}"><img riot-src="{client.widget_logo}"><span>{client.widget_subline}</span></div><div class="logo" if="{!client || !client.widget_logo}"><img src="/images/bp-org.png"></div></section>', '', '', function(opts) {
    this.mixin(AjaxMixin)
    this.mixin(FindLinkMixin)
    this.mixin(TranslationMixin)

    this.on('mount', function(){
      this.load(this.opts.record_url, 'record')

      if(this.opts.client_url) {
        this.load(this.opts.client_url, 'client')
      }
    })

    this.on('update', function() {
      if(this.record) {
        var utm = {
          utm_source: document.location.pathname.substring(1).replace(/s?\/.*/, '') + '_widget',
          utm_medium: document.location.pathname.substring(1).replace(/s?\//, '_'),
          utm_content: encodeURI(this.record.title),
          utm_campaign: 'widget',
        }
        var utm_query = '?' + Object.keys(utm).map(k => k + '=' + utm[k]).join('&');

        this.profile_picture = this.find_link(this.record.profile_picture.links, 'fill_410x214')
        this.visit_url       = this.find_link(this.record.links, 'platform') + utm_query

        if(this.client && this.client.project_url_template) {
          this.visit_url = this.client.project_url_template.replace('{project_id}', this.record.id)

        }
      }
    })
});

var AjaxMixin = {
  check_status: function(response) {
    if (response.status == 200)
      return Promise.resolve(response)
    else
      return Promise.reject(new Error(response.statusText))
  },

  json: function(response) {
    return response.json()
  },

  handle_error: function(error) {
    // console.log('Fetch Error :-S', error)
  },

  assign_target_promise: function(target) {
    return function(data) {
      this[target] = data
      this.update()
    }.bind(this)
  },

  load: function(url, assign_target) {
    fetch(url)
      .then(this.check_status)
      .then(this.json)
      .then(this.assign_target_promise(assign_target))
      .catch(this.handle_error)
  },
}

var FindLinkMixin = {
  find_link: function(links, rel) {
    for (var i = 0; i < links.length; i++) {
      if(links[i].rel === rel)
        return links[i].href
    }
  }
}

var TranslationMixin = {
  translations: {
    en: {
      donor_count:          "Donors",
      financed:             "financed",
      donate:               "View & donate",
      visit:                "Visit page",
      donations_prohibited: "Leider kann zurzeit nicht online gespendet werden.",
    },
    de: {
      donor_count:          "Spender",
      financed:             "finanziert",
      donate:               "Informieren & spenden",
      visit:                "Seite besuchen",
      donations_prohibited: "Leider kann zurzeit nicht online gespendet werden.",
    }
  },

  init: function() {
    var params = riot.route.query()
    this.lang = ['de', 'en'].indexOf(params.l) === -1 ? 'de' : params.l
    this.t = this.translations[this.lang]
   }
}

riot.tag2('widget', '<project record_url="{record_url}" client_url="{client_url}"></project>', '', '', function(opts) {
    this.api_hosts = {
      production:  'https://api.betterplace.org',
      staging:     'https://api.bp42.com',
      development: 'http://www.betterplace.dev',
    }
    this.mixin(TranslationMixin)
    var params       = riot.route.query()
    var api_host     = this.api_hosts[(params.env || 'production')]
    var api_base_url = api_host + '/' + this.lang + '/api_v4'
    this.record_url  = api_base_url + document.location.pathname

    if(params.client) {
      this.client_url = api_base_url + '/clients/' + params.client + '/widget_config'
    }
});
