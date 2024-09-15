import {Button, Card, Flex} from "antd";
import {useNavigate} from "react-router-dom";
import {Copy, Plus} from "@phosphor-icons/react";
import {useEffect, useState} from "react";

interface SyncConfig {
    id: string;
    name: string;
}


export const UserConfig = () => {
    const navigate = useNavigate();
    const [syncConfigs, setSyncConfigs] = useState([] as SyncConfig[]);

    useEffect(() => {
        fetch('https://localhost:8080/api/syncconfig/list')
            .then(response => response.json())
            .then(data => {
                console.log(data);
                setSyncConfigs(data);
            }
        );
    }, []);


    return (
        <Flex gap={24} style={{padding: 24}} wrap={"wrap"}>
            {syncConfigs.map((item) => {
                return (
                    <Card key={item.id} title={item.name} extra={<Button icon={<Copy size={'1rem'} />} />} style={{minWidth: '400px', marginBottom: 24}}>
                        <h2>{item.name}</h2>
                        <p>Erstellt am: 01.01.2021</p>
                        <p>https://localhost:8080/api/create-calendar?syncConfigId={item.id}</p>
                        <Button onClick={() => navigate('/config/' + item.id)}>Bearbeiten</Button>
                    </Card>
                );
            })}
            <Card onClick={() => navigate('/config/new')} style={{minWidth: '400px', display: 'flex', justifyContent: 'center', backgroundColor: "white", alignItems: 'center', cursor: "pointer"}}>
           <Plus size={'2rem'} color={"black"}/>
             </Card>

        </Flex>
    );
};
