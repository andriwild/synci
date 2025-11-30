import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {Button, Flex, theme, Typography} from "antd";
import {SportConfigCard} from "../../sharedComponents/config/SportConfigCard.tsx";
import {TeamConfigCard} from "../../sharedComponents/config/TeamConfigCard.tsx";
import {EventConfigCard} from "../../sharedComponents/config/EventConfigCard.tsx";
import {CalendarSelectionModal} from "../../sharedComponents/calenderSelectionModal/CalenderSelectionModal.tsx";
import {VITE_BACKEND_HOST} from "../../../env.ts";
import {syncConfigActions} from "../../services/syncConfig/syncCofigSlice.ts";
import {IconPlus, IconFileSad} from "@tabler/icons-react";
import {useDispatch} from "react-redux";
import {useNavigate} from "react-router-dom";

export const SyncConfigPage = () => {
    const syncConfig = syncConfigApi.useGetAllQuery();
    const token = theme.useToken().token;
    const dispatch = useDispatch();
    const navigate = useNavigate();

    return (
        <Flex wrap
              gap={20}
              style={{
                  padding: "20px",
                  height: "100%",
                  overflow: "auto",
              }}>
            {syncConfig?.data?.map((config) => (
                <Flex vertical key={config.id} gap={10} style={{
                    background: token.colorBgBase,
                    borderRadius: "20px",
                    maxWidth: "300px",
                    padding: "20px"
                }}>
                    <Typography.Title level={3} style={{margin: 0}}>{config.name}</Typography.Title>

                    {config.sports && config.sports.map((sport) => (
                        <SportConfigCard sport={sport} config={config} key={sport.id}/>
                    ))}

                    {config.teams && config.teams.map((team) => (
                        <TeamConfigCard team={team} config={config} key={team.id}/>
                    ))}

                    {config.events && config.events.map((event) => (
                        <EventConfigCard event={event} config={config} key={event.id}/>
                    ))}

                    {(!config.sports || config.sports.length === 0) &&
                     (!config.teams || config.teams.length === 0) &&
                     (!config.events || config.events.length === 0) && (
                        <Flex
                            vertical
                            align={"center"}
                            justify={"center"}
                            gap={10}
                            style={{
                                borderRadius: 20,
                                background: token.colorBgContainer,
                                padding: 20,
                                minHeight: "100px"
                            }}>
                            <IconFileSad size={40} color={token.colorTextSecondary}/>
                            <Typography.Text type="secondary">Keine Events</Typography.Text>
                        </Flex>
                    )}

                    <Button
                        type="default"
                        icon={<IconPlus size={20}/>}
                        onClick={() => {
                            dispatch(syncConfigActions.setSyncConfig(config));
                            navigate('/sport');
                        }}
                    >
                        Sportarten hinzufügen
                    </Button>

                    <CalendarSelectionModal
                        url={`${VITE_BACKEND_HOST}/api/calendars/${config.id}/subscribe`}
                        buttonText="Zu Kalender hinzufügen"
                        buttonIcon={<i className="fas fa-calendar-plus"></i>}
                        buttonType="primary"
                    />
                </Flex>
            ))}
        </Flex>
    );
}