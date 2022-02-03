import React, { useEffect, useState } from "react";
import { Grid } from "@material-ui/core";

import HomePageHead from "@/head/SEOHead";
import ComponentsSidebar from "@/components/componentsPageSections/ComponentsSidebar";
import ComponentsList from "@/components/componentsPageSections/ComponentsList";
import {
  ComponentsResponse,
  ComponentSubgroup,
  fetchComponents,
} from "@/components/api/fetchComponents";

export default function ComponentsPage() {
  const [isLoading, setIsLoading] = useState(true);
  const [componentsResponse, setComponentsResponse] =
    useState<ComponentsResponse>();

  const [selectedSubGroup, setSelectedSubGroup] = useState<ComponentSubgroup>();

  useEffect(() => {
    _fetchComponents();
  }, []);

  const _fetchComponents = async () => {
    await fetchComponents().then((res) => {
      setComponentsResponse(res);
      setSelectedSubGroup(res.component_groups[0].component_subgroups[0]);
      setIsLoading(false);
    });
  };
  return (
    <>
      <HomePageHead title="Browse production ready Flutter UI Components" />
      {isLoading ? (
        <div>Loading...</div>
      ) : (
        <Grid container direction="row" justifyContent="center">
          <Grid item>
            <ComponentsSidebar
              selectedSubGroup={selectedSubGroup}
              onSubGroupSelected={(subGroup) => {
                setSelectedSubGroup(subGroup);
              }}
              componentGroups={componentsResponse?.component_groups ?? []}
            />
          </Grid>
          <Grid item xs={12} md={8} lg={8}>
            {selectedSubGroup ? (
              <ComponentsList componentSubgroup={selectedSubGroup} />
            ) : (
              <div></div>
            )}
          </Grid>
        </Grid>
      )}
    </>
  );
}
