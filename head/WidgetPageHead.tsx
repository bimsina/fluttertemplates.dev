import SEOHead from "./SEOHead";

interface Props {
  title: string;
  description: string;
}
export default function WidgetPageHead(params: Props) {
  const _title = `${params.title} : Download free Flutter UI Templates for Android, iOS and Web.`;
  const _desc = `${params.title} : ${params.description}`;
  return <SEOHead title={_title} description={_desc} />;
}
