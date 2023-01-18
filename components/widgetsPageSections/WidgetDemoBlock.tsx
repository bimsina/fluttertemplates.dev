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
    _responsiveValues[0]
  );
  const [selectedTab, setSelectedTab] = React.useState(0);

  function renderTabs(selectedTab: number) {
    return (
      <div className="relative w-full h-full">
        <div
          className={`flex flex-row justify-center absolute w-full h-full rounded-md ${
            selectedTab === 0
              ? "pointer-events-auto"
              : "opacity-0 pointer-events-none bg-transparent"
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
          className={`w-full h-full absolute ${
            selectedTab !== 1 ? "opacity-0 -z-10" : ""
          }`}
        >
          <CodeBlock url={props.rawCodeUrl} height="70vh" />
        </div>

        <div
          className={`w-full h-full absolute ${
            selectedTab !== 2 ? "opacity-0 -z-10" : ""
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
        <div className="p-4 border rounded-lg border-borderColor dark:border-darkBorderColor border-opacity-20 dark:border-opacity-20">
          <div className="flex md:flex-row flex-col items-center justify-center h-full">
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
                    className={`px-3 py-1 rounded-3xl hover:bg-primary hover:text-white transition-all ${
                      index === selectedTab
                        ? "bg-primary text-primary bg-opacity-5"
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
                  className="text-xl text-gray-600 dark:text-gray-200 p-2"
                >
                  <FaGithub />
                </a>
              </div>
            </div>
          </div>
        </div>

        <div className="flex flex-row justify-center min-h-[500px] h-[70vh]">
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
              className={` h-10 w-10 inline-flex items-center justify-center rounded-lg mx-1 hover:bg-primary dark:hover:bg-primary hover:text-white transition-all ${
                responsiveSize.value === item.value
                  ? "bg-primary text-primary bg-opacity-10"
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
