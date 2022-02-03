// fetch components from the server
export const fetchComponents = async (): Promise<ComponentsResponse> => {
  let _response: ComponentsResponse = {
    base_url: "",
    component_groups: [],
  };
  await fetch(
    "https://raw.githubusercontent.com/fluttertemplates-dev/components/master/data.json"
  )
    .then((response) => response.json())
    .then((data) => {
      _response = data;
    })
    .catch((error) => {
      _response = {
        base_url: "",
        component_groups: [],
      };
    });
  return _response;
};

export interface ComponentsResponse {
  base_url: string;
  component_groups: ComponentGroup[];
}

export interface ComponentGroup {
  title: string;
  component_subgroups: ComponentSubgroup[];
}

export interface ComponentSubgroup {
  title: string;
  components: Component[];
}

export interface Component {
  title: string;
  path: string;
}
