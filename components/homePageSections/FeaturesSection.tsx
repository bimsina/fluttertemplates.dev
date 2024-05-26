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
    <div className="mx-auto px-4 py-16 sm:max-w-xl md:max-w-full md:px-24 lg:max-w-screen-xl lg:px-8 lg:py-20">
      <div className="mb-10 max-w-xl sm:text-center md:mx-auto md:mb-12 lg:max-w-2xl">
        <div>
          <p className="mb-4 inline-block px-3 py-px text-2xl font-bold">
            Features
          </p>
        </div>
      </div>
      <div className="row-gap-10 grid grid-cols-2 gap-8 md:grid-cols-3">
        {features.map((feature, index) => (
          <div
            className="flex max-w-sm flex-col items-center justify-center text-center sm:mx-auto sm:text-center"
            key={`feature${index}`}
          >
            <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-primary bg-opacity-10 text-primary sm:mx-auto sm:h-24 sm:w-24">
              {feature.icon}
            </div>
            <h6 className="mb-3 text-xl font-bold leading-5">
              {feature.title}
            </h6>
            <p className="text-md mb-3 max-w-xs text-gray-900 dark:text-gray-200">
              {feature.description}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
};

export default FeaturesSection;
