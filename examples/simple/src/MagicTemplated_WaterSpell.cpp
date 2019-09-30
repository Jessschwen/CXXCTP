#include "generated/MagicTemplated_std__string__int_.typeclass.generated.hpp"
#include "generated/WaterSpell_MagicTemplated_std__string__int_.typeclass_instance.generated.hpp"

#include <vector>
#include <iostream>

namespace cxxctp {
namespace generated {

template<>
void has_T< MagicTemplated<std::string, int>, WaterSpell >
(const WaterSpell& data, const std::string &name1, const int &name2) noexcept {
    /// \note don`t use get_concrete<type> here, it may be get_concrete<ref_type>
    std::cout << "(WaterSpell) MagicTemplated on " << name1
              << " by " << name2 << " "
              << std::endl;
}

} // namespace cxxctp
} // namespace generated