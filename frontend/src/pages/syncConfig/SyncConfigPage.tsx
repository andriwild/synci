import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {Flex, theme, Typography} from "antd";

export const SyncConfigPage = () => {
    const syncConfig = syncConfigApi.useGetAllQuery();
    const token = theme.useToken().token;
    console.log(syncConfig);

    return (
        <Flex wrap gap={10}>
            {syncConfig.data?.map((config) => (
                <Flex vertical key={config.id} gap={10} flex={"0 0 300px"}>
                    <div>{config.id}</div>
                    <div>{config.name}</div>
                    {config.sports && config.sports.map((sport) => (
                        <Flex vertical key={sport.id} gap={10}>
                            <Typography.Title level={5} color={token.colorPrimary}>{sport.name}</Typography.Title>

                        </Flex>
                    ))}
                </Flex>
            ))}
        </Flex>
    )
}

