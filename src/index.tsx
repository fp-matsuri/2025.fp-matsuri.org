export const layout = "layouts/main.tsx";
export const title = "関数型まつり";

export default () => (
  <>
    <Hero />
    <About />
    <Overview />
    <Schedule />
    <Sponsors />
    <Team />
  </>
);

const Hero = () => {
  const IconButton = ({ href, icon }: { href: string, icon: string }) => (
    <a className="icon-button" href={href} target="_blank">
      <img src={icon} alt="" />
    </a>
  );

  return (
    <div className="hero">
      <h1>関数型まつり</h1>
      <div className="date">
        2025.6.14 <span >sat</span> – 15 <span>sun</span>
      </div>
      <div className="announcement">
        セッションを募集中です(2025/3/2まで)
        <div className="buttons">
          <a className="button" href="https://fortee.jp/2025fp-matsuri/speaker/proposal/cfp" target="_blank">セッションに応募する</a>
          <a className="button" href="https://fortee.jp/2025fp-matsuri/proposal/all" target="_blank">応募中のセッション一覧を見る</a>
        </div>
      </div>
      <ul className="links">
        <IconButton href="https://x.com/fp_matsuri" icon="/assets/images/x.svg" />
        <IconButton href="https://blog.fp-matsuri.org/" icon="/assets/images/hatenablog.svg" />
        <IconButton href="https://fortee.jp/2025fp-matsuri" icon="/assets/images/fortee.svg" />
      </ul>
    </div>
  )
};

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
      <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d25918.24822641297!2d139.64379899847268!3d35.707005772578796!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x6018f34668e0bc27%3A0x7d66caba722762c5!2z5Lit6YeO44K744Oz44OI44Op44Or44OR44O844Kv44Kr44Oz44OV44Kh44Os44Oz44K5!5e0!3m2!1sen!2sjp!4v1736684092765!5m2!1sen!2sjp" width="100%" height="400" loading="lazy" />
    </Block>
  )
};

const Schedule = () => {
  const ListItem = ({ label, at }) => (
    <li className="event">
      <h3>{label}</h3>
      <p>{at}</p>
    </li>
  );

  return (
    <Block title="Schedule">
      <ul className="schedule">
        <ListItem label={<a href="https://fortee.jp/2025fp-matsuri/speaker/proposal/cfp" target="_blank">セッション応募開始</a>} at="2025年1月20日" />
        <ListItem label="セッション採択結果発表" at="2025年3月中" />
        <ListItem label="チケット販売開始" at="2025年春頃" />
        <ListItem label="関数型まつり開催" at="2025.6.14-15" />
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

const Team = () => {
  const ListItem = ({ id }) => (
    <li className="person">
      <img src={`https://github.com/${id}.png`} alt="" />
      <a href={`https://github.com/${id}`} target="_blank">{id}</a>
    </li>
  );

  return (
    <Block title="Team">
      <div className="people">
        <h3>座長</h3>
        <ul>
          {staff.leaders.map((leader, i) => (<ListItem id={leader} />))}
        </ul>
        <h3>スタッフ</h3>
        <ul>
          {staff.members.map((member, i) => (<ListItem id={member} />))}
        </ul>
      </div>
    </Block>
  )
};

const staff: { leaders: string[], members: string[] } =
{
  leaders: [
    "lagenorhynque",
    "omiend",
    "shomatan",
    "taketora26",
    "yoshihiro503",
    "ysaito8015"
  ],
  members: [
    "a-skua",
    "aoiroaoino",
    "ChenCMD",
    "Guvalif",
    "igrep",
    "ik11235",
    "Iwaji",
    "katsujukou",
    "kawagashira",
    "kazup0n",
    "Keita-N",
    "kmizu",
    "magnolia-k",
    "quantumshiro",
    "rabe1028",
    "takezoux2",
    "tanishiking",
    "tomoco95",
    "Tomoyuki-TAKEZAKI",
    "unarist",
    "usabarashi",
    "wm3",
    "y047aka",
    "yonta",
    "yshnb"
  ]
}

const Block = ({ title, children }) => (
  <section>
    <h2>{title}</h2>
    {children}
  </section>
);
