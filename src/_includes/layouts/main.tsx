
export default ({ title, children }: Lume.Data, helpers: Lume.Helpers) => (
  <html lang="ja">
    <head>
      <meta charSet="utf-8" />
      <title>{title}</title>
      <meta name="description" content="" />
      <meta name="viewport" content="width=device-width,initial-scale=1" />
      <link rel="stylesheet" href="/styles.css" />
    </head>
    <body>
      <header class="site-header" >
        <h1>
          <a href="/">関数型まつり</a>
        </h1>
        <nav>
          <a href="/code-of-conduct/">行動規範</a>
        </nav>
      </header>
      <main>
        {children}
      </main>
      <footer className="site-footer">© 2025 関数型まつり準備委員会</footer>
    </body>
  </html>
);
