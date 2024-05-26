import { MdArrowForward } from "react-icons/md";
import CustomContainedButton from "../buttons/ContainedButton";
import CustomFlatButton from "../buttons/FlatButton";

function HeroSection() {
  return (
    <div className="mx-auto flex max-w-xl flex-col justify-between bg-background px-4 dark:bg-darkBackground md:px-8 lg:max-w-screen-xl lg:flex-row lg:pt-16">
      <div className="mb-16 pt-16 lg:mb-0 lg:max-w-lg lg:pr-5 lg:pt-32">
        <div className="mb-6 max-w-xl">
          <h1 className="mb-2 font-sans text-3xl font-bold tracking-tight text-primary sm:text-4xl sm:leading-none">
            Production-ready
          </h1>
          <h1 className="mb-6 font-sans text-4xl font-bold tracking-tight text-black dark:text-white sm:text-5xl sm:leading-none">
            Flutter UI Templates
          </h1>
          <p className="text-base text-gray-700 dark:text-gray-300 md:text-lg">
            A collection of production-ready open source Flutter UI Templates
            and Widgets.
          </p>
        </div>
        <div className="flex items-center space-x-4">
          <CustomContainedButton
            href="/widgets"
            label="Browse Widgets"
            endIcon={<MdArrowForward />}
          />
          <CustomFlatButton href="/templates" label="Browse Templates" bold />
        </div>
      </div>
      <div>
        <img
          src="/home_hero.svg"
          className="mx-auto w-full object-cover object-top md:max-w-sm lg:h-auto xl:mr-24"
          alt=""
        />
      </div>
    </div>
  );
}
export default HeroSection;
