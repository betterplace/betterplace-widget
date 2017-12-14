riot.tag2('iefallback', '<div class="image" style="background-image: url(\'/images/fill_410x214_default.betterplace.jpg\');"></div><section class="content"><h1>{t.iefallback_text}</h1><div class="limited-width"><a target="_blank" class="button button-block" href="{visit_url}" style="margin-top: 15px">{t.visit}</a></div><div class="logo"><img src="/images/bp-org.png"></div></section>', '', '', function(opts) {
    this.mixin(TranslationMixin)

    this.on('update', function() {
      var path = document.location.pathname;
      path = path.replace('fundraising_events', 'fundraising-events')
      this.visit_url = 'https://www.betterplace.org' + path;
    })
});

riot.tag2('project', '<div class="image" riot-style="background-image: url(\'{profile_picture}\');"></div><section class="content"><div><h1><unsafe-html html="{record.title}"></unsafe-html></h1><div class="limited-width"><div if="{!record.donations_prohibited}" class="project-values"><div class="progress-bar" if="{record.progress_percentage}"><div class="bar" riot-style="width: {record.progress_percentage}%"></div></div><div class="donor-count"><div class="value">{record.donor_count}</div> {t.donor_count} </div><div if="{record.progress_percentage}" class="progress-percentage"><div class="value">{record.progress_percentage} %</div> {t.financed} </div></div><div class="project-status-message" if="{record.donations_prohibited}"> {t.donations_prohibited} </div><a target="_blank" class="button button-block" if="{!record.donations_prohibited}" href="{visit_url}">{t.donate}</a><a target="_blank" class="button button-block" if="{record.donations_prohibited}" href="{visit_url}">{t.visit}</a></div><div class="logo" if="{client.widget_logo}"><img riot-src="{client.widget_logo}"><span>{client.widget_subline}</span></div><div class="logo" if="{!client || !client.widget_logo}"><img class="betterplace-logo" src="/images/bp-org.png"></div><div></section>', '', '', function(opts) {
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
          utm_campaign: 'widget',
        };
        var utm_query = '?' + Object.keys(utm).map(function(k, _) { return k + '=' + utm[k] }).join('&');

        this.profile_picture = this.find_link(this.record.profile_picture.links, 'fill_410x214')
        this.visit_url       = this.find_link(this.record.links, 'platform') + utm_query

        if(this.client && this.client.project_url_template) {
          this.visit_url = this.client.project_url_template.replace('{project_id}', this.record.id)
        }
      }
    })
});

riot.tag('unsafe-html', '', function(opts) {
  var set = function() { this.root.innerHTML = opts.html || '...' }.bind(this)
  this.on('update', set)
  this.on('mount', set)
})

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
      donations_prohibited: "At the moment you can't donate online.",
      iefallback_text:      "Your version of Internet Explorer is not supported, please visit us on betterplace.org",
    },
    de: {
      donor_count:          "Spender",
      financed:             "finanziert",
      donate:               "Informieren & spenden",
      visit:                "Seite besuchen",
      donations_prohibited: "Leider kann zurzeit nicht online gespendet werden.",
      iefallback_text:      "In Ihrer Version des Internet Explorers können die Informationen leider nicht geladen werden. Bitte besuchen Sie uns direkt auf betterplace.org",
    }
  },

  init: function() {
    var params = riot.route.query()
    this.lang = ['de', 'en'].indexOf(params.l) === -1 ? 'de' : params.l
    this.t = this.translations[this.lang]
   }
}

riot.tag2('widget', '<project if="{!oldIE}" record_url="{record_url}" client_url="{client_url}"></project><iefallback if="{oldIE}"></iefallback>', '', 'class="{widgetClass}"', function(opts) {
    this.oldIE = !!window.oldIE

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

    if(params.legacy)
      this.widgetClass = 'legacy-size'

    if(params.client) {
      this.client_url = api_base_url + '/clients/' + params.client + '/widget_config'
    }
});
