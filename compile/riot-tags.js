riot.tag2('iefallback', '<div class="image" style="background-image: url(\'/images/fill_410x214_default.betterplace.jpg\');"> </div> <section class="content"> <h1>{t.iefallback_text}</h1> <div class="limited-width"> <a target="_blank" class="button button-block" href="{visit_url}" style="margin-top: 15px">{t.visit}</a> </div> <div class="logo"> <img src="/images/bp-org-logo.png"> </div> </section>', '', '', function(opts) {
    this.mixin(TranslationMixin)

    this.on('update', function() {
      var path = document.location.pathname;
      path = path.replace('fundraising_events', 'fundraising-events')
      this.visit_url = 'https://www.betterplace.org' + path;
    })
});

riot.tag2('project', '<div class="image" riot-style="background-image: url(\'{profile_picture}\');"> </div> <section class="content show-on-mini"> <h1 if="{!opts.donate_button}"><unsafe-html html="{record.title}"></unsafe-html></h1> <div class="limited-width"> <div if="{!record.donations_prohibited && !opts.donate_button}" class="project-values"> <div class="progress-bar" if="{record.progress_percentage && !opts.donate_button}"> <div class="bar" riot-style="width: {record.progress_percentage}%"> <div class="{opts.donate_button}"></div> </div> </div> </div> </div> <div class="limited-width"> <div if="{!record.donations_prohibited && !opts.donate_button}" class="project-values"> <div class="donations-count" if="{!opts.donate_button}"> <div class="value">{record.donations_count}</div> {t.donations_count} </div> <div if="{record.progress_percentage}" class="progress-percentage"> <div class="value">{record.progress_percentage} %</div> {t.financed} </div> </div> </div> <div class="limited-width"> <div class="project-status-message" if="{record.donations_prohibited}"> {t.donations_prohibited} </div> <a target="_blank" class="button button-block show-on-mini" if="{!record.donations_prohibited}" href="{visit_url}">{t.donate}</a> <a target="_blank" class="button button-block" if="{record.donations_prohibited}" href="{visit_url}">{t.visit}</a> </div> <div class="wirwunder-logos show-on-mini" if="{opts.widget_class && opts.widget_class.includes(\'wirwunder\')}"> <div class="logo"> <img src="/images/wirwunder_logo_red.svg"> </div> <div class="logo" if="{client.wirwunder_logo}"> <img riot-src="{client.wirwunder_logo}"> </div> </div> <div class="logo show-on-mini" if="{!opts.widget_class || !(opts.widget_class.includes(\'wirwunder\'))}"> <img class="betterplace-logo" src="/images/bp-org-logo.png"> </div> <a href="{t.privacy_policy_url}" target="_blank" class="privacy-policy-link" title="{t.privacy_policy_text}">i</a> </section>', '', 'class="{opts.donate_button ? \'mini\' : \'\'}"', function(opts) {
    this.mixin(AjaxMixin)
    this.mixin(FindLinkMixin)
    this.mixin(TranslationMixin)

    this.generateUtmQuery = function(utm) {
      return '?' + Object.keys(utm).map(function(k) { return k + '=' + utm[k] }).join('&');
    }

    this.on('mount', function(){
      this.load(this.opts.record_url, 'record')

      if(this.opts.client_url) {
        this.load(this.opts.client_url, 'client')
      }
    })

    this.on('update', function() {
      if(this.record) {
        var utm_medium = opts.donate_button ? 'external_banner' : document.location.pathname.substring(1).replace(/s?\//, '_')
        var utm_source = opts.donate_button ? 'projects' : (document.location.pathname.substring(1).replace(/s?\/.*/, '') + '_widget')
        var utm_content = 'bp'
        var utm = {
          utm_source: utm_source,
          utm_medium: utm_medium,
          utm_campaign: opts.donate_button ? 'donate_btn' : 'widget',
          utm_content: utm_content,
        };

        var utm_query = this.generateUtmQuery(utm);

        this.profile_picture = this.find_link(this.record.profile_picture.links, 'fill_410x214')
        this.visit_url       = this.find_link(this.record.links, 'platform') + utm_query

        if(this.client && this.client.project_url_template) {
          this.visit_url = this.client.project_url_template.replace('{project_id}', this.record.id)

          if(opts.widget_class.includes('wirwunder')) {
            utm.utm_content = 'ww'
            var utm_query = this.generateUtmQuery(utm);
            this.visit_url = this.visit_url.replace('/projects/', '/project/') + utm_query
          }
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
      donations_count:      "Donations",
      financed:             "financed",
      donate:               "Donate now",
      visit:                "Visit page",
      donations_prohibited: "At the moment you can't donate online.",
      iefallback_text:      "Your version of Internet Explorer is not supported, please visit us on betterplace.org",
      privacy_policy_url:   "https://www.betterplace.org/c/rules/privacy-policy",
      privacy_policy_text:  "View privacy policy",
    },
    de: {
      donations_count:      "Spenden",
      financed:             "finanziert",
      donate:               "Jetzt spenden",
      visit:                "Seite besuchen",
      donations_prohibited: "Leider kann zurzeit nicht online gespendet werden.",
      iefallback_text:      "In Ihrer Version des Internet Explorers können die Informationen leider nicht geladen werden. Bitte besuchen Sie uns direkt auf betterplace.org",
      privacy_policy_url:   "https://www.betterplace.org/c/regeln/datenschutz",
      privacy_policy_text:  "Datenschutzerklärung anzeigen",
    }
  },

  init: function() {
    var params = riot.route.query()
    this.lang = ['de', 'en'].indexOf(params.l) === -1 ? 'de' : params.l
    this.t = this.translations[this.lang]
   }
}

riot.tag2('widget', '<project if="{!oldIE}" record_url="{record_url}" client_url="{client_url}" widget_class="{widgetClass}" donate_button="{donateButton}"></project> <iefallback if="{oldIE}"></iefallback>', '', 'class="{widgetClass}"', function(opts) {
    this.oldIE = !!window.oldIE

    this.api_hosts = {
      production:  'https://api.betterplace.org',
      staging:     'https://api.bp42.com',
      development: 'https://api.betterplace.dev',
    }
    this.mixin(TranslationMixin)
    var params       = riot.route.query()
    var api_host     = this.api_hosts[(params.env || 'production')]
    var api_base_url = api_host + '/' + this.lang + '/api_v4'
    this.record_url  = api_base_url + document.location.pathname

    if(params.donate_button)
      this.donateButton = 'true'

    if(params.legacy)
      this.widgetClass = 'legacy-size'

    if(params.donate_button) {
      this.donateButton = 'true'
      this.widgetClass = ((this.widgetClass || '') + ' straight').trim()
    }

    if(params.wirwunder)
      this.widgetClass = ((this.widgetClass || '') + ' wirwunder').trim()

    if(params.client) {
      this.client_url = api_base_url + '/clients/' + params.client + '/widget_config'
    }
});
