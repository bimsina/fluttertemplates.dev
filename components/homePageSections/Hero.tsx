import { MdArrowForward } from "react-icons/md";
import CustomContainedButton from "../buttons/ContainedButton";
import CustomFlatButton from "../buttons/FlatButton";

function HeroSection(props: any) {
  return (
    <div className="flex flex-col justify-between max-w-xl px-4 mx-auto lg:pt-16 lg:flex-row md:px-8 lg:max-w-screen-xl bg-background">
      <div className="pt-16 mb-16 lg:mb-0 lg:pt-32 lg:max-w-lg lg:pr-5">
        <div className="max-w-xl mb-6">
          <h1 className="mb-2 font-sans text-3xl font-bold tracking-tight text-primary sm:text-4xl sm:leading-none">
            Production-ready
          </h1>
          <h1 className="mb-6 font-sans text-4xl font-bold tracking-tight text-black sm:text-5xl sm:leading-none">
            Flutter UI Templates
          </h1>
          <p className="text-base text-gray-700 md:text-lg">
            A collection of production-ready open source Flutter UI Templates
            and Widgets.
          </p>
        </div>
        <div className="flex items-center space-x-4">
          <CustomContainedButton
            href="/widgets"
            label="Browse Widgets"
            endIcon={<MdArrowForward fontSize="small" />}
          />
          <CustomFlatButton href="/templates" label="Browse Templates" bold />
        </div>
      </div>
      <div>
        <img
          src="/home_hero.svg"
          className="object-cover object-top w-full mx-auto lg:h-auto xl:mr-24 md:max-w-sm"
          alt=""
        />
      </div>
    </div>
  );
}
export default HeroSection;
