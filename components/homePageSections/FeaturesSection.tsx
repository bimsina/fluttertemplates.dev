import React from "react";
import { MdBrush, MdCode, MdVisibility } from "react-icons/md";

let features: FeatureModel[] = [
  {
    icon: <MdCode fontSize={32} />,
    title: "Completely Null Safe",
    description: "All the templates are built with pre configured null safety.",
  },
  {
    icon: <MdVisibility fontSize={32} />,
    title: "Readable Code",
    description:
      "All the templates are built keeping code readability in mind.",
  },
  {
    icon: <MdBrush fontSize={32} />,
    title: "Beautiful design",
    description:
      "Showcase the potential of Flutter through beautiful UI designs.",
  },
];

interface FeatureModel {
  icon: JSX.Element;
  title: string;
  description: string;
}

const FeaturesSection = () => {
  return (
    <div className="px-4 py-16 mx-auto sm:max-w-xl md:max-w-full lg:max-w-screen-xl md:px-24 lg:px-8 lg:py-20">
      <div className="max-w-xl mb-10 md:mx-auto sm:text-center lg:max-w-2xl md:mb-12">
        <div>
          <p className="inline-block px-3 py-px mb-4 text-2xl font-bold">
            Features
          </p>
        </div>
      </div>
      <div className="grid gap-8 row-gap-10 md:grid-cols-3 grid-cols-2">
        {features.map((feature, index) => (
          <div
            className="sm:mx-auto sm:text-center max-w-sm flex flex-col justify-center items-center text-center"
            key={`feature${index}`}
          >
            <div className="flex items-center justify-center w-16 h-16 mb-4 rounded-full bg-primary sm:mx-auto sm:w-24 sm:h-24 bg-opacity-10 text-primary">
              {feature.icon}
            </div>
            <h6 className="mb-3 text-xl font-bold leading-5">
              {feature.title}
            </h6>
            <p className="mb-3 text-md text-gray-900 dark:text-gray-200 max-w-xs">
              {feature.description}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
};

export default FeaturesSection;
