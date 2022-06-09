import { FaDesktop, FaGithub, FaMobileAlt, FaTabletAlt } from "react-icons/fa";
import React from "react";
import CodeBlock from "../shared/CodeBlock";
import { motion } from "framer-motion";
import CustomIframe from "../CustomIframe";
import { Widget } from "@/models/widget";

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
    value: "650px",
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
            selectedTab === 0 ? "opacity-0 -z-10" : ""
          }`}
        >
          <CodeBlock url={props.rawCodeUrl} height="70vh" />
        </div>
      </div>
    );
  }

  return (
    <div id={props.id} className="scroll-m-16 mb-8">
      <div className="grid grid-cols-1 gap-2">
        <div className="p-4 border rounded-lg border-gray-200">
          <div className="flex md:flex-row flex-col items-center justify-center h-full">
            <h6 className="text-xl font-bold">{props.title}</h6>
            <div className="grow">{renderResponsiveSelector()}</div>

            <div>
              <div className="flex flex-row items-center justify-end">
                {[0, 1].map((item) => (
                  <button
                    onClick={() => {
                      setSelectedTab(item);
                    }}
                    key={item}
                    className={`px-3 py-1 rounded-3xl ${
                      item === selectedTab
                        ? "bg-primary text-primary bg-opacity-10"
                        : ""
                    }`}
                  >
                    {item === 0 ? "Demo" : "Code"}
                  </button>
                ))}

                <a
                  href={props.codeUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-xl text-gray-600 p-2"
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
              className={` h-10 w-10 inline-flex items-center justify-center rounded-lg mx-1 ${
                responsiveSize.value === item.value
                  ? "bg-primary text-primary bg-opacity-10"
                  : "bg-card"
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
