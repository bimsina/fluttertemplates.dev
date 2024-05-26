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
          <div className="w-full max-w-5xl">
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
                  <h4 className="mb-2 px-8 font-bold lg:px-0">
                    {widget.title}
                  </h4>
                  <div className="grid grid-cols-2 gap-4 px-8 pb-8 md:grid-cols-3 lg:grid-cols-4 lg:px-0">
                    {widget.widget_subgroups.map((subgroup, idx) => {
                      return (
                        <a
                          href={`/widgets/${subgroup.id}`}
                          className="cursor-pointer"
                          key={`widget_subgroup${idx}`}
                        >
                          <div className="rounded-lg border-2 border-card bg-background transition-all hover:border-primary dark:border-darkCard dark:bg-darkCard dark:hover:border-primary">
                            <img
                              className="rounded-t-lg bg-primaryLight bg-opacity-10"
                              src={
                                subgroup.image ?? "images/widgets/default.svg"
                              }
                              alt={subgroup.title}
                            />

                            <h5 className="text-md p-4 tracking-tight text-gray-900 dark:text-gray-50">
                              {subgroup.title}
                            </h5>
                          </div>
                        </a>
                      );
                    })}
                  </div>
                </div>
              );
            },
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
