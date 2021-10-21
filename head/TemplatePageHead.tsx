import Head from "next/head";

interface Props {
  title: string;
  image: string;
  id: string;
}
export default function TemplatePageHead(params: Props) {
  const _title = `${params.title} : Download free Flutter UI Templates for Android, iOS and Web.`;
  const _desc = `${params.title} : Browse through a list of beautifully designed Flutter UI templates to kickstart your development. Download Free Flutter UI Templates for Android, iOS and Web.`;
  return (
    <Head>
      <title>{params.title}</title>
      <meta name="description" content="" />

      {/* <!-- Facebook Meta Tags --/> */}
      <meta
        property="og:url"
        content={"https://fluttertemplates.dev/templates/" + params.id + "/"}
      />
      <meta property="og:type" content="website" />
      <meta property="og:title" content={_title} />
      <meta property="og:description" content={_desc} />
      <meta property="og:image" content={params.image} />

      {/* <!-- Twitter Meta Tags --/> */}
      <meta name="twitter:card" content="summary_large_image" />
      <meta property="twitter:domain" content="fluttertemplates.dev" />
      <meta
        property="twitter:url"
        content={"https://fluttertemplates.dev/templates/" + params.id + "/"}
      />
      <meta name="twitter:title" content={_title} />
      <meta name="twitter:description" content={_desc} />
      <meta name="twitter:image" content={params.image} />
    </Head>
  );
}
