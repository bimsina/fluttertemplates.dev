import { MdMailOutline } from "react-icons/md";
import { GrTwitter, GrLinkedin, GrMail } from "react-icons/gr";
import { BUY_ME_A_COFFEE_LINK } from "../../constants";

interface LinkData {
  icon: JSX.Element;
  url: string;
}

const _links: LinkData[] = [
  {
    icon: <GrMail />,
    url: "mailto:timsinabibek960@gmail.com",
  },
  {
    icon: <GrTwitter />,
    url: "https://twitter.com/bimsina",
  },

  {
    icon: <GrLinkedin />,
    url: "https://www.linkedin.com/in/bimsina/",
  },
];

export default function Footer() {
  return (
    <footer className="bg-background text-gray-900 dark:bg-darkBackground dark:text-gray-50">
      <div className="mx-auto px-4 pt-16 sm:max-w-xl md:max-w-full md:px-24 lg:px-8">
        <div className="flex flex-row items-center justify-center">
          <div className="flex flex-col items-center p-4">
            <p className="mb-4 text-base font-bold  tracking-wide">
              Support Us
            </p>
            <a
              href={BUY_ME_A_COFFEE_LINK}
              target="_blank"
              rel="noopener noreferrer"
            >
              <img
                src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png"
                alt="Buy Me A Coffee"
                className="h-14"
              />
            </a>
          </div>
          <div className="flex flex-col items-center p-4">
            <p className="mb-4 text-base font-bold  tracking-wide">Contact</p>
            <div className="flex h-14 items-center justify-center gap-4 text-gray-700 dark:text-gray-200">
              {_links.map((link) => (
                <a
                  key={link.url}
                  href={link.url}
                  target="_blank"
                  referrerPolicy="no-referrer"
                  className="text-2xl hover:text-primary dark:hover:text-primary"
                >
                  {link.icon}
                </a>
              ))}
            </div>
          </div>
        </div>
        <div className="flex flex-row justify-center border-t border-gray-200 py-8 dark:border-gray-600">
          <p className="text-sm text-gray-600 dark:text-gray-400">
            Made by
            <a
              href="https://twitter.com/bimsina"
              target="_blank"
              rel="noopener noreferrer"
              style={{
                margin: "0 0.25rem",
              }}
            >
              Bibek Timsina
            </a>
            and
            <a
              href="https://github.com/bimsina/fluttertemplates.dev/graphs/contributors"
              target="_blank"
              rel="noopener noreferrer"
              style={{ marginLeft: "0.25rem" }}
            >
              contributors
            </a>
          </p>
        </div>
      </div>
    </footer>
  );
}
