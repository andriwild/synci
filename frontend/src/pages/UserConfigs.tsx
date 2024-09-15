import {Button, Card, Flex} from "antd";
import {useNavigate} from "react-router-dom";
import {Copy, Pen, Pencil, Plus} from "@phosphor-icons/react";
import {useEffect, useState} from "react";
import {SyncConfig} from "../model/SyncConfig.ts";


export const UserConfig = () => {
    const navigate = useNavigate();
    const [syncConfigs, setSyncConfigs] = useState([] as SyncConfig[]);

    useEffect(() => {
        fetch('http://localhost:8080/api/syncconfig/list')
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
                    <Card key={item.id} title={item.url} extra={
                        <Flex  justify={"end"} gap={"10px"}>
                        <Button icon={<Pencil size={'1rem'} />} onClick={() => navigate('/config/' + item.id)} color={"white"}></Button>
                        <Button icon={<Copy size={'1rem'} />} onClick={
                            () => {
                                navigator.clipboard.writeText(`https://localhost:8080/api/calendar?syncConfigId=${item.id}`);
                                alert("Der Link wurde in die Zwischenablage kopiert")
                            }
                        } color={"white"}></Button>

                    </Flex>
                        } style={{width: '400px', marginBottom: 24}}>
                        <h2>{item.url}</h2>
                        <p>Anzahl abonierter Teams:
                        {/*    {item.teams.length}*/}
                        </p>
                        <p>https://localhost:8080/api/calendar?syncConfigId={item.id}</p>

                    </Card>
                );
            })}
            <Card onClick={() => navigate('/config/new')} style={{minWidth: '400px', display: 'flex', justifyContent: 'center', backgroundColor: "white", alignItems: 'center', cursor: "pointer"}}>
           <Plus size={'2rem'} color={"black"}/>
             </Card>

        </Flex>
    );
};
