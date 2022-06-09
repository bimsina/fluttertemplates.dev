import { useTheme } from "next-themes";
import { BiMoon, BiSun } from "react-icons/bi";
import { useState, useEffect, useRef } from "react";
import { MdDesktopMac } from "react-icons/md";

function useComponentVisible(initialIsVisible: boolean) {
  const [isComponentVisible, setIsComponentVisible] =
    useState(initialIsVisible);
  const ref = useRef<HTMLDivElement>(null);

  const handleHideDropdown = (event: KeyboardEvent) => {
    if (event.key === "Escape") {
      setIsComponentVisible(false);
    }
  };

  const handleClickOutside = (event: Event) => {
    if (ref.current && !ref.current.contains(event.target as Node)) {
      setIsComponentVisible(false);
    }
  };

  useEffect(() => {
    document.addEventListener("keydown", handleHideDropdown, true);
    document.addEventListener("click", handleClickOutside, true);
    return () => {
      document.removeEventListener("keydown", handleHideDropdown, true);
      document.removeEventListener("click", handleClickOutside, true);
    };
  });

  return { ref, isComponentVisible, setIsComponentVisible };
}
interface ThemeOption {
  icon: JSX.Element;
  value: string;
}

const _themeOptions: ThemeOption[] = [
  {
    icon: <BiMoon />,
    value: "dark",
  },
  {
    icon: <BiSun />,
    value: "light",
  },
  {
    icon: <MdDesktopMac />,
    value: "system",
  },
];

const ThemeChanger = () => {
  const { systemTheme, theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  const themeButton = useRef(null);

  useEffect(() => {
    setMounted(true);
  }, []);

  const { ref, isComponentVisible, setIsComponentVisible } =
    useComponentVisible(false);

  const renderThemeChanger = () => {
    if (!mounted) return null;

    const currentTheme = theme === "system" ? systemTheme : theme;

    return (
      <div
        ref={ref}
        className="group inline-block relative text-black dark:text-white items-center bg-card dark:bg-darkCard rounded-md w-8 h-8 ml-2 text-lg justify-center"
      >
        <div className="inline-flex justify-center items-center w-full h-full">
          <button
            onClick={() => {
              setIsComponentVisible(!isComponentVisible);
            }}
            ref={themeButton}
          >
            {theme === "system" ? (
              <MdDesktopMac />
            ) : currentTheme === "dark" ? (
              <BiMoon />
            ) : (
              <BiSun />
            )}
          </button>
        </div>
        <ul
          className={`${
            isComponentVisible ? "block" : "hidden"
          } absolute text-gray-700 dark:text-gray-200 pt-1  z-10 bg-card dark:bg-darkCard shadow-lg -ml-32 rounded-lg p-2 mt-2`}
        >
          <li>
            {_themeOptions.map((item) => (
              <button
                key={item.value}
                className="rounded-sm hover:bg-background dark:hover:bg-darkBackground py-2 px-4 whitespace-no-wrap text-left w-36 flex items-center gap-2 capitalize"
                onClick={() => {
                  setTheme(item.value);
                  setIsComponentVisible(!isComponentVisible);
                }}
              >
                {item.icon}
                {item.value}
              </button>
            ))}
          </li>
        </ul>
      </div>
    );
  };

  return <div>{renderThemeChanger()}</div>;
};

export default ThemeChanger;
