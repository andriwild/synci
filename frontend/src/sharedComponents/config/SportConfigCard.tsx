import {Sport} from "../../services/sport/entities/sport.ts";
import {Button, Flex, Tag, theme, Typography} from "antd";
import {IconSitemap, IconTrash} from "@tabler/icons-react";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigDtoMapper} from "../../services/syncConfig/helpers/syncConfigHelper.ts";
import {useDispatch} from "react-redux";

export const SportConfigCard = ({sport}: { sport: Sport }) => {
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
            <IconSitemap size={40} color={token.colorPrimary}/>
                <Flex vertical gap={10}
                      align={"start"}>
                    <Typography.Title level={5}
                    style={{margin: "0"}}
                    >{sport.name}</Typography.Title>
                    <Tag color={token.colorPrimary}>Sportart</Tag>
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
                    dto.sports = dto.sports?.filter((s) => s !== sport.id);
                    const newSyncConfig = await updateSyncConfig(dto);
                    dispatch(syncConfigActions.setSyncConfig(newSyncConfig.data));
                }
                }
            />

        </Flex>
    )
}