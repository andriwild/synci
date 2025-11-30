import {Sport} from "../../services/sport/entities/sport.ts";
import {Badge, Button, Flex, Tag, theme, Typography} from "antd";
import {IconSitemap, IconTrash} from "@tabler/icons-react";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigDtoMapper} from "../../services/syncConfig/helpers/syncConfigHelper.ts";
import {useDispatch} from "react-redux";
import {SyncConfig} from "../../services/syncConfig/entities/syncConfig.ts";

export const SportConfigCard = ({sport, config}: { sport: Sport, config?: SyncConfig }) => {
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
                text={"Sportart"}
                style={{zIndex: 10}}
            >
            <Flex
                gap={20}
                align={"stretch"}
                justify={"space-between"}
                style={{borderRadius: 20, background: token.colorBgContainer,

                    padding: 20}}>

                <Flex gap={20} align={"flex-start"}>
                    <Flex gap={10}
                          align={"start"}>
                        <Typography.Title level={5}
                        style={{margin: "0"}}
                        >{sport.label}</Typography.Title>
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
            dto.sports = dto.sports?.filter((s) => s !== sport.id);
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