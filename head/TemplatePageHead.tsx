import Head from "next/head";

interface Props {
  title: string;
  image: string;
}
export default function TemplatePageHead(params: Props) {
  return (
    <Head>
      <title>{params.title}</title>
      <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0, shrink-to-fit=no"
      />
      <meta property="og:image" content={params.image} />
      <meta property="og:type" content="" />
      <meta
        name="twitter:description"
        content="Download Free Flutter UI Templates for Android, iOS and Web."
      />
      <meta
        name="description"
        content="Download Free Flutter UI Templates for Android, iOS and Web."
      />
      <meta
        name="title"
        content={`${params.title} : Download free Flutter UI Template`}
      />
      <meta
        name="twitter:title"
        content={`${params.title} : Download free Flutter UI Template`}
      />
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:image" content={params.image} />
    </Head>
  );
}
