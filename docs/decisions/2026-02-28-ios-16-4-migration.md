# Product Decision Record

## Metadados

- **Data:** 2026-02-28
- **Responsavel:** PM SkillBits
- **Status:** aprovado
- **Tema:** Migracao do deployment target de iOS 17 para iOS 16.4

## Contexto

O app SkillBits iOS tinha deployment target minimo de iOS 17, o que excluia usuarios em versoes anteriores. Para ampliar a base de usuarios potenciais, decidiu-se baixar o deployment target para iOS 16.4 sem remover funcionalidades.

## Opcoes consideradas

1. **Manter iOS 17 como minimo**
   - Pros: codigo mais limpo com `@Observable`, sem necessidade de polyfills
   - Contras: exclui ~15-20% dos dispositivos iOS ativos

2. **Migrar para iOS 16.4 com polyfills condicionais**
   - Pros: amplia base de usuarios; mantem codigo iOS 17 via `if #available`
   - Contras: ViewModels usam `ObservableObject` ao inves de `@Observable`; necessidade de helpers de compatibilidade

3. **Migrar para iOS 15**
   - Pros: base de usuarios maxima
   - Contras: perda de NavigationStack, Charts, e muitas APIs fundamentais ao app

## Decisao tomada

- **Decisao final:** Opcao 2 — migrar para iOS 16.4 com polyfills condicionais
- **Motivo:** Melhor equilibrio entre alcance de usuarios e manutencao de codigo. APIs criticas (NavigationStack, Charts, presentationDetents) estao disponiveis a partir do iOS 16.

## Impacto esperado

- **Usuario:** mais dispositivos suportados (~15-20% a mais)
- **Negocio:** maior base potencial de usuarios para MVP
- **Tecnico:** ViewModels usam `ObservableObject`; helpers `sbOnChange`, `sbNavigationDestination` e `SBUnevenRoundedRectangle` abstraem diferencas; codigo iOS 17 preservado via `if #available`

## Escopo aprovado

- Inclui:
  - Deployment target do app: iOS 16.4
  - Platform target dos SPM packages: .iOS(.v16)
  - Migracao de @Observable → ObservableObject + @Published
  - Migracao de @Bindable → @ObservedObject
  - Migracao de @State (para VMs) → @StateObject
  - Polyfills: sbOnChange, sbNavigationDestination, SBUnevenRoundedRectangle
- Nao inclui:
  - Suporte a iOS 15 ou inferior
  - Mudancas de funcionalidade ou UX

## Artefatos atualizados

- `ios/project.yml` (deployment target)
- 13 `Package.swift` (platform targets)
- 11 arquivos de ViewModel (ObservableObject)
- 7 arquivos de View (@ObservedObject/@StateObject)
- `ios/Packages/SkillBitsDesignSystem/.../Compatibility.swift` (novo)
- `docs/skillbits-master-documentation.md`
- `docs/skillbits-feature-matrix.md`
- `.cursor/skills/skillbits-ios/SKILL.md`

## Proximos passos

1. Testar em simulador iOS 16.4 para validar comportamento
2. Testar em dispositivo fisico com iOS 16.x se disponivel
3. Validar que polyfills de navegacao funcionam corretamente em fluxo de curso

## Validacao do usuario

- **Aprovado por:** usuario
- **Canal:** chat
- **Observacoes:** Solicitacao direta do usuario para ampliar suporte
