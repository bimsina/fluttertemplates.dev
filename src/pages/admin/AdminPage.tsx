import React from "react";
import { Grid } from "@material-ui/core";

import AdminWrapper from "./AdminWrapper";
import CustomButton from "../../components/custom_button";

export default function AdminPage() {
  return (
    <AdminWrapper>
      <Grid
        container
        direction="column"
        justifyContent="center"
        alignItems="center"
        spacing={2}
        style={{
          height: "80vh",
          width: "100%",
        }}
      >
        <Grid item>
          <CustomButton
            href="/addCategories"
            variant="contained"
            color="primary"
          >
            Add Categories
          </CustomButton>
        </Grid>

        <Grid item>
          <CustomButton
            href="/addTemplates"
            variant="contained"
            color="primary"
          >
            Add Templates
          </CustomButton>
        </Grid>
      </Grid>
    </AdminWrapper>
  );
}
