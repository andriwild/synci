import {Badge, Button, Flex, theme, Typography} from "antd";
import {IconTrash} from "@tabler/icons-react";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigDtoMapper} from "../../services/syncConfig/helpers/syncConfigHelper.ts";
import {useDispatch} from "react-redux";
import {SportEvent} from "../../services/event/entities/event.ts";
import {convertToSwissDate} from "../../services/common/dateUtil.ts";
import {SyncConfig} from "../../services/syncConfig/entities/syncConfig.ts";

export const EventConfigCard = ({event, config}: { event: SportEvent, config?: SyncConfig }) => {
    const [updateSyncConfig, updateSyncConfigStatus] = syncConfigApi.useUpdateMutation();
    const currentSyncConfig = useSyncConfig();
    const syncConfig = config || currentSyncConfig;
    const token = theme.useToken().token;
    const dispatch = useDispatch();

    return (
    <Flex
        align={"center"}
        justify={"stretch"}
        >

        <div style={{ margin: "10px 10px 0 0", flex: 1 }}>
            <Badge.Ribbon
                color={token.colorPrimary}
                text={"Event"}
                style={{zIndex: 10}}
            >
            <Flex
                gap={20}
                align={"stretch"}
                justify={"space-between"}
                style={{borderRadius: 20, background: token.colorBgContainer,
                    padding: 20}}>

                <Flex gap={20} align={"flex-start"}>
                    <Flex gap={10} vertical
                          align={"start"}>
                        <Flex gap={2} vertical align={"start"}>
                            {event.rootSport &&
                                <Typography.Text type={"secondary"}
                                    style={{fontSize: 12, fontWeight: 300, margin: 0, lineHeight: 1.2}}
                                >{event.rootSport}</Typography.Text>}
                            <Typography.Title level={5}
                            style={{margin: "0"}}
                            >{event.name}</Typography.Title>
                        </Flex>
                        <Typography.Text
                            style={{margin: "0"}}
                        >{convertToSwissDate(event.startsOn)}</Typography.Text>
                    </Flex>
                </Flex>

            </Flex>
            </Badge.Ribbon>
        </div>
    <Button
        type={"text"}
        icon={<IconTrash size={16}/>}
        size={"middle"}
        loading={updateSyncConfigStatus.isLoading}
        onClick={async () => {
            if (!syncConfig || !syncConfig.id) {
                return;
            }
            const dto = syncConfigDtoMapper(syncConfig);
            dto.events = dto.events?.filter((e) => e.id !== event.id);
            const newSyncConfig = await updateSyncConfig(dto);
            if (syncConfig.id === currentSyncConfig?.id) {
                dispatch(syncConfigActions.setSyncConfig(newSyncConfig.data));
            }
        }
        }
    >

    </Button>
    </Flex>
    )
}