<project class={ opts.donate_button ? 'mini' : '' }>
  <div class="image" style="background-image: url('{ profile_picture }');">
  </div>

  <section class={ 'content show-on-mini' + (record.donations_prohibited ? ' donations-prohibited' : '') }>
    <h1 if={ !opts.donate_button }><unsafe-html html={ record.title } /></h1>

    <div class="limited-width">
      <div if={ !record.donations_prohibited && !opts.donate_button} class="project-values">
        <div class="progress-bar" if={ record.progress_percentage && !opts.donate_button }>
          <div class={ "bar" + (record.progress_percentage >= 100 ? " full" : "") } style="width: { record.progress_percentage }%">
            <div class={ opts.donate_button }></div>
          </div>
        </div>
      </div>
    </div>

    <div class="limited-width">
      <div if={ !record.donations_prohibited && !opts.donate_button} class="project-values">
        <div class="donations-count" if={ !opts.donate_button }>
          <div class="value">{ record.donations_count }</div>
          { t.donations_count }
        </div>
        <div if={ record.progress_percentage} class="progress-percentage">
          <div class="value">{ record.progress_percentage } %</div>
          { t.financed }
        </div>
      </div>
    </div>

    <div class="limited-width">
      <div class="project-status-message" if={ record.donations_prohibited }>
        { t.donations_prohibited }
      </div>

      <a target="_blank" class="button button-block show-on-mini" if={ !record.donations_prohibited } href="{ visit_url }">{ t.donate }</a>
      <a target="_blank" class="button button-block" if={ record.donations_prohibited } href="{ visit_url }">{ t.visit }</a>
    </div>

    
    <div class="supported-by" if={ opts.widget_class && opts.widget_class.includes('wirwunder') }>
      { t.supported_by_wirwuder }
    </div>
    <div class="supported-by" if={ !opts.widget_class || !(opts.widget_class.includes('wirwunder')) }>
      { t.provided_by_betterplace }
    </div>  
    

    <div class={ 'wirwunder-logos show-on-mini' + (record.donations_prohibited ? ' donations-prohibited' : '') } if={ opts.widget_class && opts.widget_class.includes('wirwunder') }>
      <div class="logo" >
        <img src='/images/wirwunder_logo_red.svg'/>
      </div>

      <div class="logo" if={ client.wirwunder_logo }>
        <img src={ client.wirwunder_logo }/>
      </div>
    </div>

    <div class="logo show-on-mini" if={ !opts.widget_class || !(opts.widget_class.includes('wirwunder')) }>
      <img class="betterplace-logo" src="/images/bp-org-logo.png"/>
    </div>
    <a href="{ t.privacy_policy_url }" target="_blank" class="privacy-policy-link" title="{ t.privacy_policy_text }">i</a>
  </section>

  <script>
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
        var utm_medium = document.location.pathname.substring(1).replace(/s?\//, '_')
        var utm_source = document.location.pathname.substring(1).replace(/s?\/.*/, '')
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
  </script>

</project>
