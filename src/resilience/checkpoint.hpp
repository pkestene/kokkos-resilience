#ifndef INC_RESILIENCE_CHECKPOINT_HPP
#define INC_RESILIENCE_CHECKPOINT_HPP

#include <string>
#include <vector>
#include <memory>

#include <Kokkos_Core.hpp>
#include <Kokkos_ViewHooks.hpp>

// Tracing support
#ifdef KR_ENABLE_TRACING
#include "util/trace.hpp"
#include <sstream>
#endif

namespace KokkosResilience
{
  namespace filter
  {
    struct default_filter
    {
      bool operator()( int ) const
      { return true; }
    };
    
    template< int Freq >
    struct nth_iteration_filter
    {
      bool operator()( int i ) const { return !( i % Freq ); }
    };
  }
  
  template< typename Context, typename F, typename FilterFunc = filter::default_filter >
  void checkpoint( Context &ctx, const std::string &label, int iteration, F &&fun, FilterFunc &&filter = filter::default_filter{} )
  {
#if defined( KOKKOS_ACTIVE_EXECUTION_MEMORY_SPACE_HOST )
    
    // Trace if enabled
#ifdef KR_ENABLE_TRACING
    std::ostringstream oss;
    oss << "checkpoint_" << label;
    auto chk_trace = Util::begin_trace< Util::IterTimingTrace< std::string > >( oss.str(), iteration );
    
    auto overhead_trace = Util::begin_trace< Util::TimingTrace< std::string > >( "overhead" );
#endif
    
    using fun_type = typename std::remove_reference< F >::type;
    
    // Copy the functor, since if it has any views we can turn on view tracking
    std::vector< std::unique_ptr< Kokkos::ViewHolderBase > > views;
    
    // Don't do anything with const views since they can never be checkpointed in this context
    Kokkos::ViewHooks::set( [&views]( Kokkos::ViewHolderBase &view ) {
      views.emplace_back( view.clone() );
    }, []( Kokkos::ConstViewHolderBase & ) {} );
    
    fun_type f = fun;
    
    Kokkos::ViewHooks::clear();

#ifdef KR_ENABLE_TRACING
    overhead_trace.end();
#endif
    
    if ( ctx.backend().restart_available( label, iteration ) )
    {
      // Load views with data
#ifdef KR_ENABLE_TRACING
      auto restart_trace = Util::begin_trace< Util::TimingTrace< std::string > >( "restart" );
#endif
      ctx.backend().restart( label, iteration, views );
    } else {
      // Execute functor and checkpoint
#ifdef KR_ENABLE_TRACING
      auto function_trace = Util::begin_trace< Util::TimingTrace< std::string > >( "function" );
#endif
      fun();
#ifdef KR_ENABLE_TRACING
      function_trace.end();
#endif
  
      if ( filter( iteration ) )
      {
#ifdef KR_ENABLE_TRACING
        auto write_trace = Util::begin_trace< Util::TimingTrace< std::string > >( "write" );
#endif
        ctx.backend().checkpoint( label, iteration, views );
      }
    }
#else
#ifdef KR_ENABLE_TRACING
      auto function_trace = Util::begin_trace< Util::TimingTrace< std::string > >( "function" );
#endif
    fun();
#ifdef KR_ENABLE_TRACING
      function_trace.end();
#endif
#endif
  }
}

#endif  // INC_RESILIENCE_CHECKPOINT_HPP
