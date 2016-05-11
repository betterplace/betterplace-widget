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
  }
}

var FindLinkMixin = {
  find_link: function(links, rel) {
    for (var i = 0; i < links.length; i++) {
      if(links[i].rel === rel)
        return links[i].href
    }
  }
}

<widget>
  <div class="image" style="background-image: url('{ profile_picture }');">
    <h2>{ record.title }</h2>
  </div>

  <div class="generic-progress-bar">
    <div class="bar" style="width: { record.progress_percentage }%">
    </div>
  </div>

  <div if={ !record.donations_prohibited } class="generic-project-values">
    <div class="inner">
      <div class="donor-count">
        <div class="value">{ record.donor_count }</div>
        { t.donor_count }
      </div>
      <div class="progress-percentage">
        <div class="value">{ record.progress_percentage } %</div>
        { t.financed }
      </div>
    </div>
  </div>

  <div if={ record.donations_prohibited }>
    { t.donations_prohibited }
  </div>

  <a if={ !record.donations_prohibited } href="{ donate_url }">{ t.donate }</a>
  <a if={ record.donations_prohibited } href="{ visit_url }">{ t.visit }</a>

  <div if={ client }>
    <img src={ client.widget_logo }/>
    <span>{ client.widget_subline }</span>
  </div>
  <div if={ !client }>
    <img src="/images/bp-org.png"/>
  </div>

  this.mixin(AjaxMixin)
  this.mixin(FindLinkMixin)

  <script>
    this.on('mount', function(){
      var params = riot.route.query()

      // Set the language
      var lang = ['de', 'en'].indexOf(params.l) === -1 ? 'de' : params.l
      this.t = translations[lang]

      var api_host     = (params.api_host || 'https://www.betterplace.org')
      var api_base_url = api_host + '/' + lang + '/api_v4'

      // Load the project
      var record_url = api_base_url + '/projects/' + params.pid
      this.load(record_url, 'record')

      if(params.cid) {
        var client_url = api_base_url + '/clients/' + params.cid + '/widget_config'
        this.load(client_url, 'client')
      }
    })

    this.on('update', function() {
      if(this.record) {
        this.profile_picture = this.find_link(this.record.profile_picture.links, 'fill_410x214')
        this.donate_url      = this.find_link(this.record.links, 'new_donation')
        this.visit_url       = this.find_link(this.record.links, 'platform')
      }
    })

    var translations = {
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
    }
  </script>

</widget>
