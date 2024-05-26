import React from "react";
import TemplateCardProps from "@/models/template_card";
import getTemplatesList from "@/utils/getTemplatesList";
import HomePageHead from "@/head/SEOHead";
import { useRouter } from "next/dist/client/router";
import CircularProgress from "@/components/shared/CircularProgress";
import TemplatesGrid from "@/components/TemplatesGrid";
import SubmitProposalSection from "@/components/shared/SubmitProposalSection";
import Footer from "@/components/footer/Footer";

export default function TemplatesList({
  templates,
}: {
  templates: TemplateCardProps[];
}) {
  const router = useRouter();
  const [category, setCategory] = React.useState<string | undefined>();

  const { catId } = router.query;

  React.useEffect(() => {
    function getCat() {
      setTimeout(() => {
        const _cat = (router.query.catId ?? "all").toString();
        setCategory(_cat);
      }, 1000);
    }
    getCat();
  }, [router.query]);

  return (
    <div className="inline-flex w-full justify-center">
      <div className="w-full max-w-6xl">
        <HomePageHead />
        {!category && (
          <div className="min-h-[45vh] w-full">
            <CircularProgress />
          </div>
        )}
        {category && (
          <TemplatesGrid
            templates={templates}
            limit={false}
            selectedCatId={catId as string}
          />
        )}

        <SubmitProposalSection />

        <Footer />
      </div>
    </div>
  );
}

export async function getStaticProps() {
  const _data = getTemplatesList();
  return _data;
}
