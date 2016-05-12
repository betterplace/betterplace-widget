<project>
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
      <div if={ record.progress_percentage} class="progress-percentage">
        <div class="value">{ record.progress_percentage } %</div>
        { t.financed }
      </div>
    </div>
  </div>

  <div if={ record.donations_prohibited }>
    { t.donations_prohibited }
  </div>

  <a if={ !record.donations_prohibited } href="{ visit_url }">{ t.donate }</a>
  <a if={ record.donations_prohibited } href="{ visit_url }">{ t.visit }</a>

  <div if={ client.widget_logo }>
    <img src={ client.widget_logo }/>
    <span>{ client.widget_subline }</span>
  </div>
  <div if={ !client || !client.widget_logo }>
    <img src="/images/bp-org.png"/>
  </div>

  <script>
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
      }
    })
  </script>

</project>
