import { OrbitControls, Stats, useGLTF, Environment } from "@react-three/drei";
import { useFrame, useThree } from "@react-three/fiber";
import { EffectComposer, Bloom } from "@react-three/postprocessing";
import vertexShader from "./shaders/vertex.glsl";
import fragmentShader from "./shaders/fragment.glsl";
import * as THREE from "three";

export default function Experience() {
    const { camera } = useThree();
    const time = new THREE.Uniform(0);

    useFrame((state, delta) => {
        time.value += delta;
    });

    // import a glb model
    const { nodes } = useGLTF("./LavaLamp.glb");
    console.log(nodes);

    return (
        <>
            <Stats />
            <OrbitControls />
            <EffectComposer>
                <Bloom luminanceThreshold={0.9} intensity={2} />
            </EffectComposer>
            {/* <directionalLight
                position={[5, 5, -5]}
                intensity={1}
                color={"#ffffff"}
            />
            <directionalLight
                position={[5, 1, 0]}
                intensity={1}
                color={"#ffddaa"}
            /> */}
            <Environment
                preset="night"
                blur={0.5}
                background
                environmentIntensity={0}
            />
            <Environment
                preset="apartment"
                blur={0.5}
                background={false}
                environmentIntensity={0.6}
            />
            <mesh geometry={nodes.LampCaps.geometry} scale={0.8}>
                <meshStandardMaterial
                    color="#d4d4d4"
                    metalness={0.95}
                    roughness={0.6}
                />
            </mesh>
            <mesh geometry={nodes.LavaLampBody.geometry} scale={0.8}>
                <shaderMaterial
                    vertexShader={vertexShader}
                    fragmentShader={fragmentShader}
                    uniforms={{
                        uTime: time,
                    }}
                    transparent={true}
                />
            </mesh>
            <mesh geometry={nodes.LampBottom.geometry} scale={0.8}>
                <meshStandardMaterial color={[5, 5, 2]} toneMapped={false} />
            </mesh>
        </>
    );
}
