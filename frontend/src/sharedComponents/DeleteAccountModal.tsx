import {Button, Flex, Modal, notification, Typography} from "antd";
import {useState} from "react";
import {useDispatch} from "react-redux";
import {useAuth0} from "@auth0/auth0-react";
import {userApi} from "../services/user/userApi.ts";
import {userActions} from "../services/user/UserSlice.ts";
import {syncConfigActions} from "../services/syncConfig/syncCofigSlice.ts";

export const DeleteAccountModal = () => {
    const [open, setOpen] = useState(false);
    const [api, contextHolder] = notification.useNotification();
    const dispatch = useDispatch();
    const {logout} = useAuth0();
    const [deleteMe, deleteMeStatus] = userApi.useDeleteMeMutation();

    const handleDelete = async () => {
        const response = await deleteMe();
        // The backend reports errors in the body with HTTP 200
        if (response.error || typeof response.data !== "number") {
            api.error({
                message: "Konto konnte nicht gelöscht werden",
                description: "Bitte versuche es später noch einmal.",
                placement: "bottomRight",
            });
            return;
        }
        // Log out right away, otherwise the backend recreates the user
        dispatch(syncConfigActions.clearSyncConfig());
        dispatch(userActions.clearUser());
        await logout({logoutParams: {returnTo: window.location.origin}});
    };

    return (
        <>
            {contextHolder}
            <Button
                danger
                type={'text'}
                style={{width: '100%'}}
                onClick={() => setOpen(true)}
            >
                Konto löschen
            </Button>
            <Modal
                title="Konto löschen"
                open={open}
                onCancel={() => setOpen(false)}
                footer={null}
            >
                <Flex vertical gap={16}>
                    <Typography.Text>
                        Willst du dein Konto wirklich löschen? Alle deine Abos werden gelöscht und abonnierte
                        Kalender werden nicht mehr aktualisiert. Das lässt sich nicht rückgängig machen.
                    </Typography.Text>
                    <Button danger type="primary" loading={deleteMeStatus.isLoading} onClick={handleDelete}>
                        Konto endgültig löschen
                    </Button>
                </Flex>
            </Modal>
        </>
    );
}
