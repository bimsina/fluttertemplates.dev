import { MdFavorite } from "react-icons/md";
import { GITHUB_LINK } from "../../constants";

export default function SubmitProposalSection() {
  return (
    <section className="flex flex-col items-center justify-center min-h-[50vh] bg-primary bg-opacity-5">
      <h6 className="pb-4 text-xl font-semibold">
        Didn't find the template you were looking for?
      </h6>
      <div className="inline-flex rounded-md">
        <a
          href={`${GITHUB_LINK}/issues/new?assignees=&labels=widget_template&template=request-a-new-widget.md`}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center justify-center px-5 py-3 text-base font-medium rounded-full text-white bg-primary"
        >
          <span>Submit a proposal</span>
          <div className="ml-2">{<MdFavorite fontSize="small" />}</div>
        </a>
      </div>
    </section>
  );
}
