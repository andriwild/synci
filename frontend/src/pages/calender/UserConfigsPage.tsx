import { FC } from "react";
import { Card, Flex } from "antd";
import { Plus } from "@phosphor-icons/react";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { SyncConfig } from "../../model/SyncConfig.ts";
import { Api } from "../../services/data.tsx"
import { ConfigCard } from "../../components/ConfigCard.tsx";


export const UserConfigsPage: FC = () => {
    const navigate = useNavigate();
    const [syncConfigs, setSyncConfigs] = useState([] as SyncConfig[]);

    useEffect(() => {
        Api.getAllSycnConfigs()
            .then(data => 
                data.sort(
                    (a: SyncConfig, b: SyncConfig) => a.name.localeCompare(b.name))
            )
            .then(setSyncConfigs);
    }, []);


    const deleteConfig = (id: string) => {
        Api.deleteSyncConfig(id)
            .then(data => {
                if (data) {
                    setSyncConfigs(syncConfigs.filter(item => item.id !== id));
                }
            });
    };

    return (
        <Flex gap={24} style={{ padding: 24 }} wrap={ "wrap" }>
            { syncConfigs.map(
                (item:SyncConfig) => 
                    <ConfigCard 
                        config={ item } 
                        key={ item.id } 
                        onDelete={() => deleteConfig(item.id!)}
                    />
            )}
            <Card onClick={() => navigate('/config/new')} style={{
                minWidth: '400px', 
                display: 'flex', 
                justifyContent: 'center', 
                backgroundColor: "white", 
                alignItems: 'center', 
                cursor: "pointer"
            }}>
                <Plus size={'2rem'} color={"black"}/>
            </Card>
        </Flex>
    );
};
