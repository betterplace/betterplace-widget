<project>
  <div class="image" style="background-image: url('{ profile_picture }');">
  </div>

  <section class="content">

    <h1>{ record.title }</h1>

    <div class="limited-width">

      <div class="progress-bar" if={ record.progress_percentage }>
        <div class="bar" style="width: { record.progress_percentage }%">
        </div>
      </div>

      <div if={ !record.donations_prohibited } class="project-values">
        <div class="donor-count">
          <div class="value">{ record.donor_count }</div>
          { t.donor_count }
        </div>
        <div if={ record.progress_percentage} class="progress-percentage">
          <div class="value">{ record.progress_percentage } %</div>
          { t.financed }
        </div>
      </div>

      <div class="project-status-message" if={ record.donations_prohibited }>
        { t.donations_prohibited }
      </div>

      <a target="_blank" class="button button-block" if={ !record.donations_prohibited } href="{ visit_url }">{ t.donate }</a>
      <a target="_blank" class="button button-block" if={ record.donations_prohibited } href="{ visit_url }">{ t.visit }</a>

    </div>

    <div class="logo" if={ client.widget_logo }>
      <img src={ client.widget_logo }/>
      <span>{ client.widget_subline }</span>
    </div>

    <div class="logo" if={ !client || !client.widget_logo }>
      <img src="/images/bp-org.png"/>
    </div>

  </section>

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
