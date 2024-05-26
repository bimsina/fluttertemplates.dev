import React, { useState } from "react";
import PageNotFoundPage from "@/pages/404";
import CategoriesList from "./CategoriesList";
import Code from "./Code";
import CustomIframe from "./CustomIframe";
import PackagesUsed from "./PackagesUsed";
import TemplatePageHead from "@/head/TemplatePageHead";
import TemplateCardProps from "@/models/template_card";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import rehypeRaw from "rehype-raw";

import { MdCode, MdLink, MdInfoOutline } from "react-icons/md";

function TemplateDetailPage(params: TemplateCardProps) {
  return (
    <>
      <TemplatePageHead
        title={params.frontmatter.title}
        image={`https://fluttertemplates.dev/${params.frontmatter.image}`}
        id={params.id}
      />
      <div className="inline-flex w-full justify-center">
        <RenderBody {...params} />
      </div>
    </>
  );
}

function RenderBody(props: TemplateCardProps) {
  const _frontmatter = props.frontmatter;

  return (
    <div className="flex h-full w-full max-w-6xl flex-col md:flex-row">
      <div className="flex h-full grow flex-col justify-start p-4 ">
        <div>
          <h5 className="mb-1 ml-4 mt-4 text-xl font-bold">
            {_frontmatter.title}
          </h5>
          {_frontmatter.categories && _frontmatter.categories.length > 0 && (
            <div>
              <CategoriesList
                categories={_frontmatter.categories}
                selected={""}
                showAll={false}
              />
            </div>
          )}
        </div>
        <div className="min-h-[60vh] w-full max-w-2xl flex-grow">
          <CustomTabs {...props} />
        </div>
      </div>

      <div className="aspect-phone h-[85vh]">
        <CustomIframe
          url={_frontmatter.demoUrl}
          showLoadingIndicator={true}
          className="m-3.5 rounded-2xl border-2 border-black"
        />
      </div>
    </div>
  );
}

const CustomTabs = (props: TemplateCardProps) => {
  const [selectedTab, setSelectedTab] = useState(0);
  const handleTabChange = (newValue: number) => {
    setSelectedTab(newValue);
  };

  const _hasMdContent = (props.content ?? "").toString().length != 0;
  const _frontmatter = props.frontmatter;

  function renderTabs(selectedTab: number) {
    if (_hasMdContent && selectedTab == 0) {
      return (
        <div className="h-[80%] w-full overflow-y-auto overflow-x-hidden">
          <ReactMarkdown
            className="m-2"
            children={props.content ?? ""}
            remarkPlugins={[remarkGfm]}
            rehypePlugins={[rehypeRaw]}
            linkTarget="_blank"
            components={
              {
                // img: ({ node, ...props }) => (
                //   <img {...props} width="100%" height="100%" />
                // ),
                // tr: ({ node, ...props }) => (
                //   <Grid container spacing={1}>
                //     {props.children}
                //   </Grid>
                // ),
                // td: ({ node, ...props }) => (
                //   <Grid item xs={4}>
                //     {props.children}
                //   </Grid>
                // ),
              }
            }
          />
        </div>
      );
    } else if (
      (!_hasMdContent && selectedTab == 0) ||
      (_hasMdContent && selectedTab == 1)
    ) {
      return (
        <Code
          codeGistUrl={_frontmatter.codeGistUrl}
          fullCodeUrl={_frontmatter.codeUrl}
        />
      );
    } else if (
      (!_hasMdContent && selectedTab == 1) ||
      (_hasMdContent && selectedTab == 2)
    ) {
      return <PackagesUsed packages={_frontmatter.packages ?? []} />;
    } else {
      return <PageNotFoundPage />;
    }
  }

  const _tabs: TabItem[] = (
    _hasMdContent
      ? [
          {
            label: "About",
            icon: <MdInfoOutline />,
          },
        ]
      : []
  ).concat([
    {
      label: "Code",
      icon: <MdCode />,
    },
    {
      label: "Packages Used",
      icon: <MdLink />,
    },
  ]);
  return (
    <div className="flex flex-col">
      <div className="mb-2 border-b border-gray-200 dark:border-gray-700">
        <ul className="flex flex-wrap">
          {_tabs.map((tab, index) => (
            <li className="mr-2 cursor-pointer" key={`tab${index}`}>
              <button
                onClick={() => handleTabChange(index)}
                className={
                  selectedTab === index
                    ? "inline-flex rounded-t-lg border-b-2 border-blue-600 p-4 text-sm text-blue-600 dark:border-blue-500 dark:text-blue-500"
                    : "inline-flex rounded-t-lg p-4 text-sm text-gray-600 dark:text-gray-200"
                }
              >
                <div className="mr-2 text-xl">{tab.icon}</div>
                {tab.label}
              </button>
            </li>
          ))}
        </ul>
      </div>

      <div className="h-full w-full">{renderTabs(selectedTab)}</div>
    </div>
  );
};

interface TabItem {
  label: string;
  icon: JSX.Element;
}
export default TemplateDetailPage;
