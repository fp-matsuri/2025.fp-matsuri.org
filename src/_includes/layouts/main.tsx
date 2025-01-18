
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
      <header>
        <h1>関数型まつり</h1>
      </header>
      <main>
        {children}
      </main>
    </body>
  </html>
);
