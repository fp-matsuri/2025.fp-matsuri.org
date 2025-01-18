export const layout = "layouts/main.tsx";
export const title = "関数型まつり";

export default () => (
  <>
    <About />
    <Overview />
    <Schedule />
    <Sponsors />
  </>
);

const About = () => (
  <Block title="About">
    <div>
      <p>関数型プログラミングのカンファレンス「関数型まつり」を開催します！</p>
      <p>関数型プログラミングはメジャーな言語・フレームワークに取り入れられ、広く使われるようになりました。そしてその手法自体も進化し続けています。その一方で「関数型プログラミング」というと「難しい・とっつきにくい」という声もあり、十分普及し切った状態ではありません。</p>
      <p>私たちは様々な背景の方々が関数型プログラミングを通じて新しい知見を得て、交流ができるような場を提供することを目指しています。普段から関数型言語を活用している方や関数型プログラミングに興味がある方はもちろん、最先端のソフトウェア開発技術に興味がある方もぜひご参加ください！</p>
    </div>
  </Block>
);

const Overview = () => {
  const Item = ({ name, children }: { name: string, children: string[] }) => (
    <div>
      <h3 className="font-semibold">{name}</h3>
      <p>{children}</p>
    </div>
  );

  return (
    <Block title="Overview">
      <div className="prose">
        <Item name="Dates">2025.6.14(土)〜15(日)</Item>
        <Item name="Place">中野セントラルパーク カンファレンス</Item>
      </div>
    </Block >
  )
};

const Schedule = () => {
  const events: { event: string, at: string }[] =
    [
      { event: "セッション応募開始", at: "2025年初め" },
      { event: "セッション採択結果発表", at: "" },
      { event: "チケット販売開始", at: "2025年春頃" },
      { event: "関数型まつり開催", at: "2025.6.14-15" }
    ];

  return (
    <Block title="Schedule">
      <ul className="schedule">
        {events.map((eee, i) => (
          <li className="event">
            <h3>{eee.event}</h3>
            <p>{eee.at}</p>
          </li>
        ))}
      </ul>
      <p className="note">記載されているスケジュールの一部は予告なく変更されることがございます。</p>
    </Block>
  )
};

const Sponsors = () => (
  <Block title="Sponsors">
    <div className="sponsors">
      <div className="text-3xl font-bold text-center py-8">スポンサー募集中！</div>
      <div className="text-md">
        <p>関数型まつりの開催には、みなさまのサポートが必要です！現在、イベントを支援していただけるスポンサー企業を募集しています。関数型プログラミングのコミュニティを一緒に盛り上げていきたいという企業のみなさま、ぜひご検討ください。</p>
        <p>
          スポンサープランの詳細は、2025年初頭に公開を予定しております。
          ご興味をお持ちの企業様は、ぜひ<a href="https://scalajp.notion.site/1566d12253aa80229b3bc0a015497cb4?pvs=105">お問い合わせフォーム</a>よりお気軽にご連絡ください。後日、担当者よりご連絡を差し上げます。
        </p>
      </div>
    </div>
  </Block>
);

const Block = ({ title, children }) => (
  <section>
    <h2>{title}</h2>
    {children}
  </section>
);
