<iefallback>
  <div class="image" style="background-image: url('/images/fill_410x214_default.betterplace.jpg');">
  </div>

  <section class="content">
    <h1>{ t.iefallback_text }</h1>

    <div class="limited-width">
      <a target="_blank" class="button button-block" href="{ visit_url }" style='margin-top: 15px'>{ t.visit }</a>
    </div>

    <div class="logo">
      <img src="/images/bp-org-logo.png"/>
    </div>
  </section>

  <script>
    this.mixin(TranslationMixin)

    this.on('update', function() {
      var path = document.location.pathname;
      path = path.replace('fundraising_events', 'fundraising-events')
      this.visit_url = 'https://www.betterplace.org' + path;
    })
  </script>
</iefallback>
