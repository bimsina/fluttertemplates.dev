import { Grid, Typography, useTheme } from "@mui/material";
import {
  BrushRounded,
  Edit,
  FavoriteRounded,
  HelpOutline,
} from "@mui/icons-material";
import { GITHUB_LINK } from "../../constants";
import CustomContainedButton from "../buttons/ContainedButton";

export default function SubmitProposalSection() {
  const theme = useTheme();
  return (
    <section
      style={{
        height: "50vh",
        marginTop: "5rem",
        marginBottom: "5rem",
        backgroundColor: `${theme.palette.secondary.main}10`,
      }}
    >
      <Grid
        container
        direction="column"
        justifyContent="center"
        alignItems="center"
        style={{
          height: "100%",
        }}
      >
        <Grid item>
          <Typography
            variant="h6"
            align="center"
            style={{
              fontWeight: "bold",
            }}
          >
            Didn't find the template you were looking for?
          </Typography>
        </Grid>

        <Grid
          item
          style={{
            marginTop: "1rem",
          }}
        >
          <a
            href={`${GITHUB_LINK}/issues/new?assignees=&labels=widget_template&template=request-a-new-widget.md`}
            target="_blank"
            rel="noopener noreferrer"
          >
            <CustomContainedButton
              label="Submit a proposal"
              endIcon={<FavoriteRounded fontSize="small" />}
            />
          </a>
        </Grid>
      </Grid>
    </section>
  );
}
