# 🎲 Lotería con Foundry

Un contrato inteligente de lotería desarrollado con Foundry, donde los usuarios pueden comprar tickets y un ganador es elegido aleatoriamente.

## 📋 Tabla de Contenidos

- [Características](#características)
- [Instalación y Configuración](#instalación-y-configuración)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Comandos Principales](#comandos-principales)
- [Cómo Funciona](#cómo-funciona)
- [Testing](#testing)
- [Deployment](#deployment)
- [Análisis de Gas](#análisis-de-gas)
- [Consideraciones de Seguridad](#consideraciones-de-seguridad)

## ✨ Características

- 🎫 **Compra de Tickets**: Los usuarios pueden comprar tickets con un precio fijo
- 🎰 **Selección Aleatoria**: El ganador se elige usando un algoritmo pseudoaleatorio
- 💰 **Premio Automático**: El ganador recibe todo el balance del contrato
- 🔄 **Múltiples Rondas**: Se pueden iniciar nuevas loterías después de cada ronda
- 🔒 **Control de Acceso**: Solo el owner puede elegir ganador y iniciar nuevas rondas
- 📊 **Eventos**: Emite eventos para todas las acciones importantes

## 🛠 Instalación y Configuración

### Prerrequisitos

1. **Docker Desktop** (debe estar ejecutándose)
2. **Git** para Windows
3. **VS Code** (recomendado)

### Pasos de Instalación

1. **Clonar el repositorio**:

   ```bash
   git clone <tu-repo-url>
   cd lottery-with-foundry
   ```

2. **Instalar Foundry** (usar Git BASH en Windows):

   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   source ~/.bashrc
   foundryup
   ```

3. **Verificar instalación**:

   ```bash
   forge --version
   cast --version
   anvil --version
   ```

4. **Compilar el proyecto**:

   ```bash
   forge build
   ```

5. **Ejecutar tests**:
   ```bash
   forge test
   ```

## 📁 Estructura del Proyecto

```
lottery-with-foundry/
├── .devcontainer/          # Configuración para Dev Containers
├── src/
│   ├── Counter.sol         # Contrato de ejemplo (original de Foundry)
│   └── Lottery.sol         # 🎯 Contrato principal de la lotería
├── test/
│   ├── Counter.t.sol       # Tests del contrato de ejemplo
│   └── Lottery.t.sol       # 🧪 Tests del contrato de lotería
├── script/
│   ├── Counter.s.sol       # Script de deployment de ejemplo
│   └── DeployLottery.s.sol # 🚀 Script de deployment de la lotería
├── lib/
│   └── forge-std/          # Librería estándar de Foundry
├── foundry.toml           # ⚙️ Configuración de Foundry
└── README.md              # 📖 Esta documentación
```

## 🔧 Comandos Principales

> **Importante**: En Windows, usar siempre **Git BASH** para los comandos de Foundry, no PowerShell.

### Compilación

```bash
# Compilar todos los contratos
forge build

# Compilar con información adicional
forge build --sizes
```

### Testing

```bash
# Ejecutar todos los tests
forge test

# Tests con output detallado
forge test -vvv

# Reporte de gas de los tests
forge test --gas-report

# Ejecutar tests específicos
forge test --match-test test_PlayerCanEnterLottery

# Tests con coverage
forge coverage
```

### Formateo y Limpieza

```bash
# Formatear código Solidity
forge fmt

# Limpiar archivos compilados
forge clean
```

### Deployment

```bash
# Simulación local del deployment
forge script script/DeployLottery.s.sol

# Deploy en blockchain local (Anvil)
anvil  # En una terminal separada
forge script script/DeployLottery.s.sol --fork-url http://localhost:8545 --broadcast

# Deploy en testnet (ejemplo Sepolia)
forge script script/DeployLottery.s.sol \
  --rpc-url https://sepolia.infura.io/v3/TU_API_KEY \
  --private-key TU_PRIVATE_KEY \
  --broadcast \
  --verify
```

## 🎮 Cómo Funciona

### 1. **Creación de la Lotería**

- El contrato se despliega con un precio de ticket específico (ej: 0.01 ETH)
- La lotería se activa automáticamente al desplegar

### 2. **Compra de Tickets**

```solidity
// Los usuarios llaman a esta función con el valor exacto del ticket
lottery.enterLottery{value: 0.01 ether}();
```

### 3. **Selección del Ganador**

```solidity
// Solo el owner puede ejecutar esto
lottery.pickWinner();
```

### 4. **Nueva Ronda**

```solidity
// El owner puede iniciar una nueva lotería
lottery.startNewLottery(0.02 ether); // Nuevo precio de ticket
```

### Funciones de Vista

```solidity
lottery.getPlayersCount();    // Número de jugadores
lottery.getTotalPrize();      // Premio total acumulado
lottery.getPlayers();         // Lista de jugadores
lottery.lotteryActive();      // Estado de la lotería
```

## 🧪 Testing

El proyecto incluye tests completos que cubren:

- ✅ **Configuración inicial correcta**
- ✅ **Compra de tickets**
- ✅ **Validación de precios**
- ✅ **Múltiples jugadores**
- ✅ **Control de acceso**
- ✅ **Selección de ganador**
- ✅ **Transferencia de premios**
- ✅ **Gestión de estado**
- ✅ **Emisión de eventos**
- ✅ **Fuzz testing**

### Ejecutar Tests Específicos

```bash
# Test de compra de tickets
forge test --match-test test_PlayerCanEnterLottery -vvv

# Test de selección de ganador
forge test --match-test test_PickWinnerTransfersPrize -vvv

# Fuzz testing
forge test --match-test testFuzz_EnterLotteryWithDifferentTicketPrices -vvv
```

## 🚀 Deployment

### Opción 1: Blockchain Local (Anvil)

1. **Iniciar Anvil**:

   ```bash
   anvil
   ```

   Esto te dará 10 cuentas con 10,000 ETH cada una.

2. **Deployar**:
   ```bash
   forge script script/DeployLottery.s.sol \
     --fork-url http://localhost:8545 \
     --broadcast \
     --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
   ```

### Opción 2: Testnet (Sepolia)

1. **Configurar variables de entorno**:

   ```bash
   # Crear archivo .env
   touch .env
   ```

   Agregar al `.env`:

   ```env
   PRIVATE_KEY=tu_private_key_aqui
   SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/tu_api_key
   ETHERSCAN_API_KEY=tu_etherscan_api_key
   ```

2. **Deployar**:
   ```bash
   source .env
   forge script script/DeployLottery.s.sol \
     --rpc-url $SEPOLIA_RPC_URL \
     --private-key $PRIVATE_KEY \
     --broadcast \
     --verify \
     --etherscan-api-key $ETHERSCAN_API_KEY
   ```

## ⛽ Análisis de Gas

### Costos de Deployment

- **Lottery Contract**: ~924,970 gas (~$25-50 dependiendo del gas price)

### Costos de Funciones

| Función             | Gas Promedio | Descripción             |
| ------------------- | ------------ | ----------------------- |
| `enterLottery()`    | ~71,014      | Comprar un ticket       |
| `pickWinner()`      | ~37,203      | Elegir ganador          |
| `startNewLottery()` | ~52,367      | Iniciar nueva ronda     |
| `getPlayersCount()` | ~2,440       | Ver número de jugadores |
| `getTotalPrize()`   | ~356         | Ver premio total        |

### Optimizaciones Aplicadas

- Uso de `payable[]` para eficiencia en transferencias
- Eventos indexados para búsqueda eficiente
- Funciones de vista para consultas sin gas
- Limpieza de estado después de cada ronda

## 🔒 Consideraciones de Seguridad

### ⚠️ Advertencias Importantes

1. **Aleatoriedad**: El contrato usa `keccak256` con variables de bloque para generar aleatoriedad. **NO es criptográficamente seguro** para producción.

2. **Para Producción**: Usar [Chainlink VRF](https://docs.chain.link/vrf/v2/introduction) para aleatoriedad verdadera.

3. **Reentrancy**: El contrato está protegido contra reentrancy al cambiar el estado antes de transferir.

### 🛡️ Mejoras para Producción

```solidity
// Ejemplo con Chainlink VRF
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract SecureLottery is VRFConsumerBase {
    // Implementar Chainlink VRF para aleatoriedad real
}
```

### 🔍 Auditoría Recomendada

Antes de usar en mainnet:

- [ ] Auditoría de seguridad profesional
- [ ] Implementar Chainlink VRF
- [ ] Tests de stress con múltiples usuarios
- [ ] Revisión de límites de gas
- [ ] Análisis de MEV (Maximal Extractable Value)

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

## 🎯 Próximos Pasos

- [ ] Implementar Chainlink VRF para aleatoriedad segura
- [ ] Agregar interfaz web con React
- [ ] Implementar límites de tiempo para rondas
- [ ] Añadir comisión para el owner
- [ ] Crear sistema de múltiples premios
- [ ] Agregar whitelist para jugadores VIP

---

**¡Desarrollado con ❤️ y Foundry!**
