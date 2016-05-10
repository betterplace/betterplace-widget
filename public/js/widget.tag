<widget >
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

  <script>
    this.on('mount', function(){
      var params = this.extract_params()

      // Set the language
      var lang = ['de', 'en'].indexOf(params.l) === -1 ? 'de' : params.l
      this.t = translations[lang]

      // Load the project
      this.load(params.pid)
    })

    this.on('update', function() {
      if(this.record) {
        this.profile_picture = this.find_link(this.record.profile_picture.links, 'fill_410x214')
        this.donate_url      = this.find_link(this.record.links, 'new_donation')
        this.visit_url       = this.find_link(this.record.links, 'platform')
        }
    })

    extract_params() {
      var qs = document.location.search.split('+').join(' ')
      var params = {}, tokens, re = /[?&]?([^=]+)=([^&]*)/g;

      while (tokens = re.exec(qs)) {
        params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
      }
      return params;
    }

    find_link(links, rel) {
      for (var i = 0; i < links.length; i++) {
        if(links[i].rel === rel)
          return links[i].href
      }
    }

    check_status(res) {
      if (res.status == 200)
        return Promise.resolve(res)
      else
        return Promise.reject(new Error(res.statusText))
    }

    json(res) { return res.json() }

    assign_record(data) {
      console.log(data)
      this.record = data
      this.update()
    }

    handle_error(err) {
      console.log('Fetch Error :-S', err)
    }

    load(project_id) {
      fetch('https://www.betterplace.org/de/api_v4/projects/' + project_id)
        .then(this.check_status)
        .then(this.json)
        .then(this.assign_record)
        .catch(this.handle_error)
   }

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
