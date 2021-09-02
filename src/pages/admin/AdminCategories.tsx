import React, { useMemo } from "react";
import {
  Backdrop,
  CircularProgress,
  Grid,
  List,
  ListItem,
  ListItemText,
  TextField,
  IconButton,
  ListItemSecondaryAction,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogContentText,
  DialogActions,
} from "@material-ui/core";

import CustomButton from "../../components/custom_button";
import firebase from "../../firebase/clientApp";
import { useCollection } from "react-firebase-hooks/firestore";
import { Delete, Edit } from "@material-ui/icons";
import { useForm, Controller, SubmitHandler } from "react-hook-form";
import AdminWrapper from "./AdminWrapper";

interface IFormInput {
  title: string;
}

export default function AdminCategories() {
  const { control, handleSubmit } = useForm<IFormInput>();

  const onSubmit: SubmitHandler<IFormInput> = (data) => {
    firebase.firestore().collection("categories").add(data);
  };

  const [value, loading, error] = useCollection(
    firebase.firestore().collection("categories"),
    {
      snapshotListenOptions: { includeMetadataChanges: true },
    }
  );

  return (
    <AdminWrapper>
      <div>
        <Grid
          container
          direction="column"
          justifyContent="center"
          alignItems="center"
          spacing={2}
          style={{
            height: "100vh",
            width: "100%",
          }}
        >
          {error && <strong>Error: {JSON.stringify(error)}</strong>}

          {value && (
            <List>
              {value.docs.map((_doc) => (
                <SingleComponent val={_doc} key={_doc.id} />
              ))}
            </List>
          )}

          <Grid item>
            <form onSubmit={handleSubmit(onSubmit)}>
              <Controller
                name="title"
                control={control}
                defaultValue=""
                render={({ field }) => (
                  <TextField {...field} label="Add category" variant="filled" />
                )}
              />

              <CustomButton
                variant="contained"
                color="primary"
                style={{
                  margin: "8px",
                }}
                onClick={handleSubmit(onSubmit)}
              >
                Add
              </CustomButton>
            </form>
          </Grid>
        </Grid>
        <Backdrop open={loading}>
          <CircularProgress color="inherit" />
        </Backdrop>
      </div>
    </AdminWrapper>
  );
}

interface SingleComponentProps {
  val: firebase.firestore.QueryDocumentSnapshot<firebase.firestore.DocumentData>;
}
function SingleComponent(props: SingleComponentProps) {
  function onDelete(id: string) {
    firebase.firestore().collection("categories").doc(id).delete();
  }
  const [open, setOpen] = React.useState(false);

  const handleClickOpen = () => {
    setOpen(true);
  };

  const handleClose = () => {
    setOpen(false);
  };

  const { control, handleSubmit } = useForm<IFormInput>({
    defaultValues: useMemo(() => props.val.data(), [props]),
  });

  const onSubmit: SubmitHandler<IFormInput> = (data) => {
    setOpen(false);
    firebase
      .firestore()
      .collection("categories")
      .doc(props.val.id)
      .update(data);
  };

  return (
    <div>
      <ListItem
        style={{
          width: "300px",
        }}
      >
        <ListItemText primary={props.val.data().title} />
        <ListItemSecondaryAction>
          <IconButton
            edge="end"
            onClick={() => {
              onDelete(props.val.id);
            }}
          >
            <Delete />
          </IconButton>

          <IconButton edge="end" aria-label="edit" onClick={handleClickOpen}>
            <Edit />
          </IconButton>
        </ListItemSecondaryAction>
      </ListItem>
      <form onSubmit={handleSubmit(onSubmit)}>
        <Dialog
          open={open}
          onClose={handleClose}
          aria-labelledby="form-dialog-title"
        >
          <DialogTitle id="form-dialog-title">Update</DialogTitle>
          <DialogContent>
            <Controller
              name="title"
              control={control}
              defaultValue={props.val.data().title}
              render={({ field }) => (
                <TextField
                  {...field}
                  label="Update category"
                  variant="filled"
                  key="Update key"
                />
              )}
            />
          </DialogContent>
          <DialogActions>
            <CustomButton onClick={handleClose} color="primary">
              Cancel
            </CustomButton>
            <CustomButton onClick={handleSubmit(onSubmit)} color="primary">
              Update
            </CustomButton>
          </DialogActions>
        </Dialog>
      </form>
    </div>
  );
}
