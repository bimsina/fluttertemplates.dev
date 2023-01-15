import { WidgetsResponse } from "@/models/widget";
import WidgetPageHead from "@/head/WidgetPageHead";
import getWidgetsList from "@/utils/getWidgetsList";
import SubmitProposalSection from "@/components/shared/SubmitProposalSection";
import Footer from "@/components/footer/Footer";

export default function WidgetsPage({
  componentsResponse,
}: {
  componentsResponse: WidgetsResponse;
}) {
  return (
    <>
      <WidgetPageHead title="Widgets" description="" />

      <div>
        <div className="inline-flex w-full justify-center">
          <div className="max-w-5xl w-full">
            <>{renderWidgetGrid()}</>
          </div>
        </div>
        <SubmitProposalSection />

        <Footer />
      </div>
    </>
  );

  function renderWidgetGrid() {
    return (
      <>
        <div className="grid grid-cols-1 py-4">
          {(componentsResponse?.widget_groups ?? []).map(
            (widget, index: number) => {
              return (
                <div className="flex flex-col" key={`widget_group${index}`}>
                  <h4 className="font-bold mb-2 px-8 lg:px-0">
                    {widget.title}
                  </h4>
                  <div className="grid lg:grid-cols-4 md:grid-cols-3 grid-cols-2 gap-4 pb-8 px-8 lg:px-0">
                    {widget.widget_subgroups.map((subgroup, idx) => {
                      return (
                        <a
                          href={`/widgets/${subgroup.id}`}
                          className="cursor-pointer"
                          key={`widget_subgroup${idx}`}
                        >
                          <div className="bg-background dark:bg-darkCard rounded-lg border-2 border-card dark:border-darkCard hover:border-primary dark:hover:border-primary transition-all">
                            <img
                              className="rounded-t-lg bg-primaryLight bg-opacity-10"
                              src={
                                subgroup.image ?? "images/widgets/default.svg"
                              }
                              alt={subgroup.title}
                            />

                            <h5 className="text-md tracking-tight text-gray-900 dark:text-gray-50 p-4">
                              {subgroup.title}
                            </h5>
                          </div>
                        </a>
                      );
                    })}
                  </div>
                </div>
              );
            }
          )}
        </div>
      </>
    );
  }
}

export const getStaticProps = async () => {
  const componentsResponse = await getWidgetsList();

  return {
    props: {
      componentsResponse,
    },
  };
};
