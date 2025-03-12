import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {Badge, Flex, theme, Typography} from "antd";
import {SportConfigCard} from "../../sharedComponents/config/SportConfigCard.tsx";
import {TeamConfigCard} from "../../sharedComponents/config/TeamConfigCard.tsx";
import {EventConfigCard} from "../../sharedComponents/config/EventConfigCard.tsx";
import {CalendarSelectionModal} from "../../sharedComponents/calenderSelectionModal/CalenderSelectionModal.tsx";
import {VITE_BACKEND_HOST} from "../../../env.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {IconSquare, IconSquareCheck} from "@tabler/icons-react";
import {useDispatch} from "react-redux";

export const SyncConfigPage = () => {
    const syncConfig = syncConfigApi.useGetAllQuery();
    const token = theme.useToken().token;
    const currentSyncConfig = useSyncConfig();
    const dispatch = useDispatch();

    return (
        <Flex wrap
              gap={20}
              style={{
                  padding: "20px",
                  height: "100%",
                  overflow: "auto",
              }}>
            {syncConfig.data?.map((config) => (
                <Badge count={
                    (currentSyncConfig?.id == config.id) ? <IconSquareCheck size={20} color={"green"}/> :
                        <IconSquare size={20} onClick={
                        async () => {
                            dispatch(syncConfigActions.setSyncConfig(config));
                        }
                    }/>
                }
                       style={{cursor: "pointer"}}
                       offset={[-5, 5]}>
                <Flex vertical key={config.id} gap={10} style={{
                background: token.colorBgBase,
                borderRadius: "20px",
                maxWidth: "300px",
                padding: "20px"}}>
                <Typography.Title level={3} style={{margin: 0}}>{config.name}</Typography.Title>
            {config.sports && config.sports.map((sport) => (
                <SportConfigCard sport={sport} key={sport.id}/>
    )
)
}
    {
        config.teams && config.teams.map((team) => (
            <TeamConfigCard team={team} key={team.id}/>
        ))
    }
    {
        config.events && config.events.map((event) => (
            <EventConfigCard event={event} key={event.id}/>
        ))
    }
    <CalendarSelectionModal
        url={`${VITE_BACKEND_HOST}/api/calendars/${config.id}/subscribe`}
        buttonText="Zu Kalender hinzufügen"
        buttonIcon={<i className="fas fa-calendar-plus"></i>}
        buttonType="primary"
    />
</Flex>
</Badge>
))
}
</Flex>
)
;
}