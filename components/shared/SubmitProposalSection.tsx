import { MdFavorite } from "react-icons/md";
import { GITHUB_LINK } from "../../constants";
import CustomContainedButton from "../buttons/ContainedButton";

export default function SubmitProposalSection() {
  return (
    <section className="flex flex-col items-center justify-center min-h-[50vh] bg-primary bg-opacity-5">
      <h6 className="pb-4 text-xl font-semibold">
        Didn't find the template you were looking for?
      </h6>

      <CustomContainedButton
        label="Submit a proposal"
        href={`${GITHUB_LINK}/issues/new?assignees=&labels=widget_template&template=request-a-new-widget.md`}
        endIcon={<MdFavorite />}
        target="_blank"
        rel="noopener noreferrer"
      />
    </section>
  );
}
