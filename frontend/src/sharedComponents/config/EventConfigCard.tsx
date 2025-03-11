import {Button, Flex, Tag, theme, Typography} from "antd";
import {IconCalendarEvent, IconTrash} from "@tabler/icons-react";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigDtoMapper} from "../../services/syncConfig/helpers/syncConfigHelper.ts";
import {useDispatch} from "react-redux";
import {SportEvent} from "../../services/event/entities/event.ts";
import {convertToSwissDate} from "../../services/common/dateUtil.ts";

export const EventConfigCard = ({event}: { event: SportEvent }) => {
    const [updateSyncConfig, updateSyncConfigStatus] = syncConfigApi.useUpdateMutation();
    const syncConfig = useSyncConfig();
    const token = theme.useToken().token;
    const dispatch = useDispatch();

    return (
        <Flex
            gap={20}
            align={"center"}
            justify={"space-between"}
            style={{borderRadius: 20, background: token.colorBgContainer, padding: 20}}>
            <Flex gap={20} align={"center"}>
            <IconCalendarEvent size={40} color={token.colorPrimary}/>
                <Flex vertical gap={5}
                      align={"start"}>
                    <Typography.Title level={5}
                    style={{margin: "0"}}
                    >{event.name}</Typography.Title>
                    <Typography.Text
                        style={{margin: "0"}}
                    >{convertToSwissDate(event.startsOn)}</Typography.Text>
                    <Tag color={token.colorPrimary}>Event</Tag>
                </Flex>
            </Flex>
            <Button
                type={"default"}
                icon={<IconTrash size={20}/>}
                loading={updateSyncConfigStatus.isLoading}
                onClick={async () => {
                    if (!syncConfig || !syncConfig.id) {
                        return;
                    }
                    const dto = syncConfigDtoMapper(syncConfig);
                    dto.events = dto.events?.filter((e) => e.id !== event.id);
                    const newSyncConfig = await updateSyncConfig(dto);
                    dispatch(syncConfigActions.setSyncConfig(newSyncConfig.data));
                }
                }
            />

        </Flex>
    )
}