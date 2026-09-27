<template>
  <main class="page-shell">
    <header class="masthead">
      <p class="eyebrow">Application / 01</p>
      <p class="edition">Technology overview</p>
    </header>

    <section class="overview" aria-labelledby="page-title">
      <div class="intro">
        <p class="section-label">The stack, at a glance</p>
        <h1 id="page-title">Simple by design.<br /><span>Ready to build.</span></h1>
        <p class="summary">A clear view of the technologies behind this application.</p>
      </div>

      <div class="stack-list" aria-label="Application technology stack">
        <article class="stack-item backend">
          <p class="stack-label">Backend</p>
          <h2>FastAPI</h2>
          <p class="stack-note">Python API framework</p>
          <span class="stack-index" aria-hidden="true">01</span>
        </article>

        <article class="stack-item frontend">
          <p class="stack-label">Frontend</p>
          <h2>Vue</h2>
          <p class="stack-note">Progressive JavaScript framework</p>
          <span class="stack-index" aria-hidden="true">02</span>
        </article>
      </div>
    </section>

    <footer class="footer">
      <span>SKB / FastAPI + Vue</span>
      <span>Application stack overview</span>
    </footer>
  </main>
</template>