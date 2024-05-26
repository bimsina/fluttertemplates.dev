import { FaDesktop, FaGithub, FaMobileAlt, FaTabletAlt } from "react-icons/fa";
import React from "react";
import CodeBlock from "../shared/CodeBlock";
import { motion } from "framer-motion";
import CustomIframe from "../CustomIframe";
import { Widget } from "@/models/widget";
import PackagesUsed from "../PackagesUsed";

interface ResponsiveProp {
  value: string;
  icon: JSX.Element;
  label: string;
}

const _responsiveValues: ResponsiveProp[] = [
  {
    label: "Mobile",
    value: "400px",
    icon: <FaMobileAlt />,
  },
  {
    label: "Tablet",
    value: "550px",
    icon: <FaTabletAlt />,
  },
  {
    label: "Desktop",
    value: "900px",
    icon: <FaDesktop />,
  },
];

function WidgetDemoBlock(props: Widget) {
  const [responsiveSize, setResponsiveSize] = React.useState(
    _responsiveValues[0],
  );
  const [selectedTab, setSelectedTab] = React.useState(0);

  function renderTabs(selectedTab: number) {
    return (
      <div className="relative h-full w-full">
        <div
          className={`absolute flex h-full w-full flex-row justify-center rounded-md ${
            selectedTab === 0
              ? "pointer-events-auto"
              : "pointer-events-none bg-transparent opacity-0"
          }`}
        >
          <motion.div
            animate={{
              maxWidth: responsiveSize.value,
            }}
            style={{
              height: "100%",
              width: "100%",
            }}
          >
            <CustomIframe url={props.demoUrl} showLoadingIndicator={false} />
          </motion.div>
        </div>
        <div
          className={`absolute h-full w-full ${
            selectedTab !== 1 ? "-z-10 opacity-0" : ""
          }`}
        >
          <CodeBlock url={props.rawCodeUrl} height="70vh" />
        </div>

        <div
          className={`absolute h-full w-full ${
            selectedTab !== 2 ? "-z-10 opacity-0" : ""
          }`}
        >
          <PackagesUsed packages={props.packages} />
        </div>
      </div>
    );
  }

  return (
    <div id={props.id} className="mb-8 scroll-mt-24">
      <div className="grid grid-cols-1 gap-2">
        <div className="rounded-lg border border-borderColor border-opacity-20 p-4 dark:border-darkBorderColor dark:border-opacity-20">
          <div className="flex h-full flex-col items-center justify-center md:flex-row">
            <h6 className="text-xl font-bold">{props.title}</h6>
            <div className="grow">{renderResponsiveSelector()}</div>

            <div>
              <div className="flex flex-row items-center justify-end gap-1">
                {((props.packages ?? []).length > 0
                  ? ["Demo", "Code", "Packages"]
                  : ["Demo", "Code"]
                ).map((item, index) => (
                  <button
                    onClick={() => {
                      setSelectedTab(index);
                    }}
                    key={`Tab_${index}`}
                    className={`rounded-3xl px-3 py-1 transition-all hover:bg-primary hover:text-white ${
                      index === selectedTab
                        ? "bg-primary bg-opacity-5 text-primary"
                        : ""
                    }`}
                  >
                    {item}
                  </button>
                ))}

                <a
                  href={props.codeUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="p-2 text-xl text-gray-600 dark:text-gray-200"
                >
                  <FaGithub />
                </a>
              </div>
            </div>
          </div>
        </div>

        <div className="flex h-[70vh] min-h-[500px] flex-row justify-center">
          {renderTabs(selectedTab)}
        </div>
      </div>
    </div>
  );

  function renderResponsiveSelector() {
    return (
      <motion.div
        animate={{
          scale: selectedTab == 0 ? 1 : 0,
        }}
      >
        <div className="flex items-center justify-center">
          {_responsiveValues.map((item) => (
            <button
              onClick={() => {
                setResponsiveSize(item);
              }}
              key={item.value}
              className={` mx-1 inline-flex h-10 w-10 items-center justify-center rounded-lg transition-all hover:bg-primary hover:text-white dark:hover:bg-primary ${
                responsiveSize.value === item.value
                  ? "bg-primary bg-opacity-10 text-primary"
                  : "bg-card dark:bg-darkCard"
              }`}
            >
              {item.icon}
            </button>
          ))}
        </div>
      </motion.div>
    );
  }
}

export default WidgetDemoBlock;
