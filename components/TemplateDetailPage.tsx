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
    <div className="flex h-full w-full flex-col md:flex-row max-w-6xl">
      <div className="grow flex flex-col p-4 justify-start h-full ">
        <div>
          <h5 className="mt-4 ml-4 mb-1 font-bold text-xl">
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
        <div className="flex-grow min-h-[60vh] max-w-2xl w-full">
          <CustomTabs {...props} />
        </div>
      </div>

      <div className="h-[85vh] aspect-phone">
        <CustomIframe
          url={_frontmatter.demoUrl}
          showLoadingIndicator={true}
          style={{
            borderRadius: "16px",
            margin: "16px",
            border: "2px solid black",
          }}
        />
      </div>
    </div>
  );
}

const CustomTabs = (props: TemplateCardProps) => {
  const [selectedTab, setSelectedTab] = useState(0);
  const handleTabChange = (newValue: any) => {
    setSelectedTab(newValue);
  };

  const _hasMdContent = props.content.toString().length != 0;
  const _frontmatter = props.frontmatter;

  function renderTabs(selectedTab: number) {
    if (_hasMdContent && selectedTab == 0) {
      return (
        <div className="w-full h-[80%] overflow-x-hidden overflow-y-auto">
          <ReactMarkdown
            className="m-2"
            children={props.content}
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
      <div className="border-b border-gray-200 dark:border-gray-700 mb-2">
        <ul className="flex flex-wrap">
          {_tabs.map((tab, index) => (
            <li className="mr-2 cursor-pointer" key={`tab${index}`}>
              <button
                onClick={() => handleTabChange(index)}
                className={
                  selectedTab === index
                    ? "text-sm inline-flex p-4 text-blue-600 rounded-t-lg border-b-2 border-blue-600 dark:text-blue-500 dark:border-blue-500"
                    : "text-sm inline-flex p-4 text-gray-600 rounded-t-lg dark:text-gray-200"
                }
              >
                <div className="text-xl mr-2">{tab.icon}</div>
                {tab.label}
              </button>
            </li>
          ))}
        </ul>
      </div>

      <div className="w-full h-full">{renderTabs(selectedTab)}</div>
    </div>
  );
};

interface TabItem {
  label: string;
  icon: JSX.Element;
}
export default TemplateDetailPage;
