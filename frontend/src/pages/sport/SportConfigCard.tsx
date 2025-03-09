import {Sport} from "../../services/sport/entities/sport.ts";
import {Button, Flex, Tag, theme, Typography} from "antd";
import {IconCalendarWeek, IconTrash} from "@tabler/icons-react";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";

export const SportConfigCard = ({sport}: { sport: Sport }) => {
    const [updateSyncConfig, updateSyncConfigStatus] = syncConfigApi.useUpdateMutation();
    const syncConfig = useSyncConfig();
    const token = theme.useToken().token;
    return (
        <Flex
            gap={20}
            align={"center"}
            justify={"space-between"}
            style={{borderRadius: 20, background: token.colorBgContainer, padding: 20}}>
            <Flex gap={20} align={"center"}>
            <IconCalendarWeek size={40} color={token.colorPrimary}/>
                <Flex vertical gap={10}
                      align={"start"}>
                    <Typography.Title level={4}
                    style={{margin: "0"}}
                    >{sport.name}</Typography.Title>
                    <Tag color={token.colorPrimary}>Sportart</Tag>
                </Flex>
            </Flex>
            <Button
                type={"default"}
                icon={<IconTrash size={20}/>}
                onClick={() => {


                }
                }
            />

        </Flex>
    )
}