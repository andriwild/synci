import {Button, Flex, Tag, theme, Typography} from "antd";
import {IconTrash, IconUsersGroup} from "@tabler/icons-react";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigDtoMapper} from "../../services/syncConfig/helpers/syncConfigHelper.ts";
import {useDispatch} from "react-redux";
import {Team} from "../../services/team/entities/team.ts";

export const TeamConfigCard = ({team}: { team: Team }) => {
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
            <IconUsersGroup size={40} color={token.colorPrimary}/>
                <Flex vertical gap={10}
                      align={"start"}>
                    <Typography.Title level={5}
                    style={{margin: "0"}}
                    >{team.name}</Typography.Title>
                    <Tag color={token.colorPrimary}>Team</Tag>
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
                    dto.teams = dto.teams?.filter((s) => s.id !== team.id);
                    const newSyncConfig = await updateSyncConfig(dto);
                    dispatch(syncConfigActions.setSyncConfig(newSyncConfig.data));
                }
                }
            />

        </Flex>
    )
}